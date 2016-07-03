defmodule Tensor do
  defstruct [:identity, contents: %{}, dimensions: [1]]

  defimpl Inspect do
    def inspect(tensor, opts) do 
      case length(tensor.dimensions) do
        1 ->
          Vector.Inspect.inspect(tensor, opts)
        2 ->
          Matrix.Inspect.inspect(tensor, opts)
        _ ->
          "#Tensor-(#{tensor.dimensions |> Enum.join("x")}) (#{inspect tensor.contents})"
      end
    end
  end

  def vector?(%Tensor{dimensions: [_]}), do: true
  def vector?(%Tensor{}), do: false
  def matrix?(%Tensor{dimensions: [_,_]}), do: true
  def matrix?(%Tensor{}), do: false



  @behaviour Access

  @doc """
  Returns a Tensor of one dimension less, containing all fields for which the highest-dimension accessor matches.
  """
  def fetch(tensor, key) do
    if vector?(tensor) do # Return item inside vector.
      {:ok, tensor.contents[key]}
    else
      # Return lower dimension slice of tensor.
      contents = tensor.contents[key]
      if contents do
        dimensions = tl(tensor.dimensions)
        {:ok, %Tensor{identity: tensor.identity, contents: contents, dimensions: dimensions}}
      else 
        :error
      end
    end
  end

  def pop(tensor, key) do
    raise "TODO: Implement Access.pop"
  end

  def get_and_update(tensor, key, fun) do
    raise "TODO: Implement Access.get_and_update"
  end




  def new(list_of_values, identity \\ fn _ -> nil end, dimensions \\ nil) do
    dimensions = dimensions || length(list_of_values)
    contents = chunk_list_in_dimensions(list_of_values, dimensions)
    Tensor.new(contents: contents, identity: identity, dimensions: dimensions)
  end

  # At the lowest level, do not apply chunking.
  # _do_ take only at most dimension.
  def chunk_list_in_dimensions(list, [h]) when is_integer(h) do
    Enum.take(list, h)
  end

  def chunk_list_in_dimensions(list, [h | t]) when is_integer(h) do
    list
    |> Enum.chunk(h)
    |> Enum.map(&chunk_list_in_dimensions(&1, t))
  end

  # def nested_list_to_tuple_map(list, map, tuple) do
  #   list
  #   |> Enum.map do

  #   end
  # end

  # Thank you, Ben Wilson!
  # def from_list(list) do
  #   {_, matrix} = do_from_list(list, [], %{})
  #   matrix
  # end

  # defp do_from_list(list, indices, matrix) do
  #   Enum.reduce(list, {0, matrix}, fn
  #     sublist, {idx, matrix} when is_list(sublist) ->
  #       {_sublist_idx, map} = do_from_list(sublist, [idx | indices], matrix)
  #       {idx + 1, map}
  #     item, {idx, matrix} ->
  #       coordinates =
  #         [idx | indices]
  #         |> Enum.reverse
  #         |> List.to_tuple

  #       {idx + 1, Map.put(matrix, coordinates, item)}
  #   end)
  # end

  def from_list(list) do
    list
    |> Enum.with_index
    |> Enum.reduce(%{}, fn 
      {sublist, index}, map when is_list(sublist) ->
        Map.put(map, index, from_list(sublist))
      {item, index}, map -> 
        Map.put(map, index, item)
    end)
  end

end
