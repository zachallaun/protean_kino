defmodule Protean.Kino.Machine do
  @moduledoc false

  use Kino.JS, assets_path: "lib/protean_kino/machine_assets"
  use Kino.JS.Live

  def new(config) do
    ast = smcat_ast([config.root])
    IO.inspect(ast)
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
      name: human_id(node.id)
    }
  end

  defp smcat_transitions(node) do
    node_id = human_id(node.id)

    Enum.map(node.transitions, fn transition ->
      %{
        from: node_id,
        to: human_id(hd(transition.target_ids))
      }
    end)
  end

  defp human_id(node_id) do
    node_id
    |> Enum.reverse()
    |> Enum.map(&to_string/1)
    |> Enum.join(".")
  end
end
