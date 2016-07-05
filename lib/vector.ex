defmodule Vector do
  import Kernel, except: [length: 1]
  defmodule Inspect do
    @doc false
    def inspect(vector, opts) do
      "#Vector-(#{hd vector.dimensions})#{inspect Vector.to_list(vector)}"
    end
  end

  def new() do
    Tensor.new([], [0], 0)
  end

  def new(length_or_list, identity \\ 0)

  def new(list, identity) when is_list(list) do
    Tensor.new(list, [length(list)], identity)
  end

  def new(length, identity) when is_number(length) do
    Tensor.new([], [length], identity)
  end

  def length(vector) do
    hd(vector.dimensions)
  end

  def to_list(vector) do
    Tensor.to_list(vector)
  end

  def from_list(list, identity \\ 0) do
    Tensor.new(list, [length(list)], identity)
  end

  def reverse(vector = %Tensor{dimensions: [l]}) do
    new_contents =
      for {i, v} <- vector.contents, into: %{} do
        {l-1 - i, v}
      end
    %Tensor{vector | contents: new_contents}
  end

  def dot_product(a = %Tensor{dimensions: [l]}, b = %Tensor{dimensions: [l]}) do
    products = 
      for i <- 0..(l-1) do
        a[i] * b[i]
      end
    Enum.sum(products)
  end
  def dot_product(a, b), do: raise "Two Vectors have to have the same length to be able to compute the dot product"


end
