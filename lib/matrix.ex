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

  def new(width, height, identity \\ 0) when width > 0 and height > 0 do
    %Tensor{identity: identity, dimensions: [width, height]}
  end

  def to_list(matrix) do
    Tensor.to_list(matrix)
  end

  def identity(identity \\ 1, size) when size > 0 do
    elems = Stream.cycle([identity]) |> Enum.take(size)
    diag(elems, 0)
  end

  def diag(list = [_|_], identity \\ 0) when is_list(list) do
    size = length(list)
    matrix = new(size, size, identity)
    list
    |> Enum.with_index
    |> Enum.reduce(matrix, fn {e, i}, mat -> 
      put_in(mat, [i,i], e)
    end)
  end
end
