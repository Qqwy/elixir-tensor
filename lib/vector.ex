defmodule Vector do
  defmodule Inspect do
    def inspect(vector, opts) do
      "#Vector-(#{hd vector.dimensions})#{inspect vector.contents}"
    end
  end

  def length(vector) do
    hd(vector.dimensions)
  end

  def to_list(vector) do
    for i <- (0..Vector.length(vector)) do
      #vector[i]
    end
  end
end
