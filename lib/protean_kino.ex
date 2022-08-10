defmodule Protean.Kino do
  @moduledoc """
  Livebook visualization for Protean machines.
  """

  use Kino.JS, assets_path: "lib/assets"

  def new(ast) do
    Kino.JS.new(__MODULE__, ast)
  end
end
