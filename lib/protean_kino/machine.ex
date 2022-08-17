defmodule Protean.Kino.Machine do
  @moduledoc false

  use Kino.JS, assets_path: "lib/protean_kino/machine_assets"
  use Kino.JS.Live

  def new(config) do
    ast = smcat_ast([config.root])
    Kino.JS.Live.new(__MODULE__, ast)
  end

  def replace(kino, ast) do
    Kino.JS.Live.cast(kino, {:replace, ast})
  end

  @impl true
  def init(ast, ctx) do
    {:ok, assign(ctx, ast: ast)}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, ctx.assigns.ast, ctx}
  end

  @impl true
  def handle_cast({:replace, ast}, ctx) do
    broadcast_event(ctx, "replace", ast)
    {:noreply, assign(ctx, ast: ast)}
  end

  defp smcat_ast(nodes) do
    %{
      states: Enum.map(nodes, &smcat_node/1),
      transitions: Enum.flat_map(nodes, &smcat_transitions/1)
    }
  end

  defp smcat_node(%{type: :compound} = node) do
    node
    |> node_common()
    |> Map.put(:type, "regular")
    |> Map.put(:statemachine, smcat_ast(node.states))
  end

  defp smcat_node(%{type: :parallel} = node) do
    node
    |> node_common()
    |> Map.put(:type, "parallel")
    |> Map.put(:statemachine, smcat_ast(node.states))
  end

  defp smcat_node(%{type: :final} = node) do
    node
    |> node_common()
    |> Map.put(:type, "final")
  end

  defp smcat_node(%{type: :atomic} = node) do
    node
    |> node_common()
    |> Map.put(:type, "regular")
  end

  defp node_common(node) do
    %{
      name: human_id(node.id),
      actions: entry_actions(node) ++ exit_actions(node)
    }
  end

  defp entry_actions(node) do
    List.wrap(node.entry)
    |> Enum.map(&smcat_action(&1, "entry"))
  end

  defp exit_actions(node) do
    List.wrap(node.exit)
    |> Enum.map(&smcat_action(&1, "exit"))
  end

  defp smcat_action(action, type) do
    %{type: type, body: action_description(action)}
  end

  defp action_description(%Protean.Action{module: Protean.Action, arg: arg}) do
    inspect(arg)
  end

  defp action_description(action) do
    inspect(action)
  end

  defp smcat_transitions(node) do
    node_id = human_id(node.id)

    Enum.map(node.transitions, fn transition ->
      actions =
        transition.actions
        |> Enum.map(&action_description/1)
        |> Enum.join(", ")

      %{
        from: node_id,
        to: human_id(hd(transition.target_ids)),
        label: smcat_event(transition),
        action: actions
      }
    end)
  end

  defp smcat_event(transition) do
    transition
    |> format_event()
    |> maybe_add_guard(transition)
    |> maybe_add_actions(transition)
  end

  defp maybe_add_guard(s, %{guard: nil}), do: s
  defp maybe_add_guard(s, %{guard: guard}), do: s <> " [#{inspect(guard)}]"

  defp maybe_add_actions(s, %{actions: []}), do: s

  defp maybe_add_actions(s, %{actions: actions}) do
    action_s = actions |> Enum.map(&action_description/1) |> Enum.join(", ")
    s <> " / " <> action_s
  end

  defp format_event(%{_meta: %{expr: expr}}), do: Macro.to_string(expr)
  defp format_event(%{match?: value}), do: inspect(value)

  defp human_id(node_id) do
    node_id
    |> Enum.reverse()
    |> Enum.map(&to_string/1)
    |> Enum.join(".")
  end
end
