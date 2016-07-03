defmodule Vector do
  import Kernel, except: [length: 1]
  defmodule Inspect do
    def inspect(vector, opts) do
      "#Vector-(#{hd vector.dimensions})#{inspect Vector.to_list(vector)}"
    end
  end

  def new(list, identity \\ nil) do
    Tensor.new(list, [Kernel.length(list)], identity)
  end

  def length(vector) do
    hd(vector.dimensions)
  end

  def to_list(vector) do
    for i <- (0..Vector.length(vector)-1) do
      vector[i]
    end
  end

  def from_list(list) do
    Tensor.new(list)
  end
end
