defmodule Protean.Kino do
  @moduledoc """
  Livebook visualization for Protean machines.
  """

  def machine(arg), do: Protean.Kino.Machine.new(arg)
end
