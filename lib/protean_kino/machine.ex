defmodule Protean.Kino.Machine do
  @moduledoc false

  use Kino.JS, assets_path: "lib/protean_kino/machine_assets"
  use Kino.JS.Live

  def new(ast) do
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
end
