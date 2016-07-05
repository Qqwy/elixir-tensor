defmodule Vector do
  import Kernel, except: [length: 1]
  defmodule Inspect do
    @doc false
    def inspect(vector, opts) do
      "#Vector-(#{hd vector.dimensions})#{inspect Vector.to_list(vector)}"
    end
  end

  def new(length, identity \\ nil) do
    Tensor.new([], [length], identity)
  end

  def length(vector) do
    hd(vector.dimensions)
  end

  def to_list(vector) do
    for i <- (0..Vector.length(vector)-1) do
      vector[i]
    end
  end

  def from_list(list, identity \\ nil) do
    Tensor.new(list)
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
