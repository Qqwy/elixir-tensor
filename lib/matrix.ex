defmodule Matrix do
  defmodule Inspect do
    def inspect(matrix, opts) do
      contents_inspect = matrix 
        |> Matrix.to_list()
        |> Enum.map(&Enum.join(&1, ",\t"))
        |> Enum.join("|\n|")
      "#Matrix-(#{matrix.dimensions |> Enum.join("x")})\n|#{contents_inspect}|"
    end
  end

  def to_list(matrix) do
    Tensor.to_list(matrix)
  end
end
