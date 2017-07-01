defmodule Tensor do
  @moduledoc """
  Tensor library namespace.

  use `use Tensor` to alias `Tensor`, `Matrix` and `Vector`.
  """
  defmacro __using__(_opts) do
    quote do
      alias Tensor.{Vector, Matrix, Tensor}
    end
  end
end
