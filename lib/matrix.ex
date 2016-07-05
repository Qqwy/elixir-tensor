defmodule Matrix do
  defmodule Inspect do
    def inspect(matrix, opts) do
      "#Matrix-(#{matrix.dimensions |> Enum.join("x")})#{inspect_contents(matrix)}"
    end

    defp inspect_contents(matrix) do
      contents_inspect = 
        matrix
        |> Matrix.to_list
        |> Enum.map(fn row -> 
          row 
          |> Enum.map(fn elem -> 
            elem
            |> inspect
            |> String.pad_leading(8)
          end) 
          |> Enum.join(",") 
        end)
      #  |> Enum.join("│\n│")
      top_row_length = String.length(List.first(contents_inspect))
      bottom_row_length = String.length(List.last(contents_inspect))
      top = ["\n┌", String.pad_trailing("", top_row_length), "┐\n│"] |> Enum.join
      bottom = ["│\n└", String.pad_trailing("", bottom_row_length), "┘\n"] |> Enum.join

      [top, contents_inspect |> Enum.join("│\n│"), bottom] |> Enum.join
    end
  end

  def new(width, height, identity \\ 0) do
    %Tensor{identity: identity, dimensions: [width, height]}
  end

  def to_list(matrix) do
    Tensor.to_list(matrix)
  end
end
