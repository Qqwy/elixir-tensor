defmodule Tensor.Tensor.Inspect do
  alias Tensor.{Tensor}
  def inspect(tensor, _opts) do
    """
    #Tensor<(#{dimension_string(tensor)})
    #{inspect_tensor_contents(tensor)}
    >
    """
  end

  def dimension_string(tensor) do
    tensor.dimensions |> Enum.join("×")
  end

  defp inspect_tensor_contents(tensor = %Tensor{dimensions: dimensions}) when length(dimensions) == 3 do

    [_, deepness | _] = Tensor.dimensions(tensor)

    tensor
    |> Tensor.to_list
    |> Enum.map(fn slice ->
        slice
        |> Enum.with_index
        |> Enum.map(fn {row, index} ->
          rowstr =
            row
            |> Enum.map(fn elem ->
              elem
              |> inspect
              |> String.pad_leading(8)
            end)
            |> Enum.join(",")
          "#{String.pad_leading("", 2 * index)}#{color(deepness, rem(index, deepness))}#{rowstr}#{IO.ANSI.reset}"
        end)
        |> Enum.join("\n")
    end)
    |> Enum.join(slice_join_str(deepness))

  end

  defp inspect_tensor_contents(tensor, is \\ []) do
    tensor
    |> Tensor.slices
    |> Enum.with_index
    |> Enum.map(fn {slice, i} ->
      IO.inspect(slice.dimensions)
      if Tensor.order(slice) <= 3 do
        """
        #{inspect(:lists.reverse([i|is]))}
        #{inspect_tensor_contents(slice)}
        """
      else
        inspect_tensor_contents(slice, [i|is])
      end
    end)
    |> Enum.join("\n\n\n")
  end

  defp color(deepness, depth) when deepness <= 3, do: [[IO.ANSI.bright, IO.ANSI.white], [IO.ANSI.white], [IO.ANSI.bright, IO.ANSI.black]] |> Enum.fetch!(depth)
  defp color(deepness, depth) when deepness <= 5, do: [[IO.ANSI.bright, IO.ANSI.white], [IO.ANSI.white], [IO.ANSI.bright, IO.ANSI.blue], [IO.ANSI.blue], [IO.ANSI.bright, IO.ANSI.black]] |> Enum.fetch!(depth)
  defp color(deepness, depth) when deepness <= 6, do: [[IO.ANSI.bright, IO.ANSI.white], [IO.ANSI.white], [IO.ANSI.yellow], [IO.ANSI.bright, IO.ANSI.blue], [IO.ANSI.blue], [IO.ANSI.bright, IO.ANSI.black]] |> Enum.fetch!(depth)
  defp color(_deepness, _depth), do: [IO.ANSI.white]

  defp slice_join_str(deepness) when deepness < 4, do: "\n"
  defp slice_join_str(_deepness), do: "\n\n"
end
