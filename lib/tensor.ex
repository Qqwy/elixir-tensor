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
          "#Tensor-(#{tensor.dimensions |> Enum.join("×")}) (#{inspect tensor.contents})"
      end
    end
  end

  @doc """
  Returs true if the tensor is a 1-order Tensor, which is also known as a Vector.
  """
  def vector?(%Tensor{dimensions: [_]}), do: true
  def vector?(%Tensor{}), do: false

  @doc """
  Returs true if the tensor is a 2-order Tensor, which is also known as a Matrix.
  """
  def matrix?(%Tensor{dimensions: [_,_]}), do: true
  def matrix?(%Tensor{}), do: false


  @doc """
  Returns the _order_ of the Tensor.

  This is 1 for Vectors, 2 for Matrices, etc.
  It is the amount of dimensions the tensor has.
  """
  def order(tensor) do
    length(tensor.dimensions)
  end

  @doc """
  Returns the dimensions of the tensor.
  """
  def dimensions(tensor = %Tensor{}) do 
    tensor.dimensions
  end

  @doc """
  Returns the identity, the default value a tensor inserts at a position when no other value is set.

  This is mostly used internally, and is used to allow Tensors to take a lot less space because 
  only values that are not `empty` have to be stored.
  """
  def identity(tensor = %Tensor{}) do 
    tensor.identity
  end


  @behaviour Access

  @doc """
  Returns a Tensor of one order less, containing all fields for which the highest-order accessor matches.
  In the case of a Vector, returns the bare value at the given location.

  This is part of the Access Behaviour implementation for Tensor.
  """
  def fetch(tensor, key) do
    if vector?(tensor) do # Return item inside vector.
      {:ok, Map.get(tensor.contents, key, tensor.identity)}
    else
      # Return lower dimension slice of tensor.
      contents = Map.get(tensor.contents, key, %{})
      if contents do
        dimensions = tl(tensor.dimensions)
        {:ok, %Tensor{identity: tensor.identity, contents: contents, dimensions: dimensions}}
      else 
        :error
      end
    end
  end

  @doc """
  Returns and removes the value associated with `key` from the tensor.

  Notice that because of how Tensors are structured, the structure of the tensor will not change.
  Values are basically reset to the 'identity' value.

  This is part of the Access Behaviour implementation for Tensor.
  """
  def pop(tensor, key, default \\ nil) do
    #raise "TODO: Implement Access.pop"
    Map.pop(tensor.contents, key, default)
  end

  def get_and_update(tensor, key, fun) do
    # TODO: Raise if key not numeric.
    # TODO: Raise if key outside of dimension bounds.
    if key < 0 || key >= hd(tensor.dimensions) do
      raise "invalid key #{key} while doing get_and_update on Tensor."
    end
    {result, contents} = 
      if vector? tensor do
        {result, contents} = Map.get_and_update(tensor.contents, key, fun)
      else
        {:ok, ll_tensor} = fetch(tensor, key)
        {result, ll_tensor2} = fun.(ll_tensor)
        {result, Map.put(tensor.contents, key, ll_tensor2.contents)}
      end
    {result, %Tensor{tensor | contents: contents}}
  end



  @doc """
  Creates a new Tensor from a list of lists (of lists of lists of ...).
  The second argument should be the dimensions the tensor should become.
  The optional third argument is an identity value for the tensor, that all non-set values will default to.
  """
  def new(nested_list_of_values, dimensions \\ nil, identity \\ nil) do
    dimensions = dimensions || [length(nested_list_of_values)]
    # TODO: Dimension inference.
    contents = 
      nested_list_of_values
      |> nested_list_to_nested_map
    %Tensor{contents: contents, identity: identity, dimensions: dimensions}
  end



  # At the lowest level, do not apply chunking.
  # _do_ take only at most dimension.
  # def chunk_list_in_dimensions(list, [h]) when is_integer(h) do
  #   Enum.take(list, h)
  # end

  # def chunk_list_in_dimensions(list, [h | t]) when is_integer(h) do
  #   list
  #   |> Enum.chunk(h)
  #   |> Enum.map(&chunk_list_in_dimensions(&1, t))
  # end

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

  defp nested_list_to_nested_map(list) do
    list
    |> Enum.with_index
    |> Enum.reduce(%{}, fn 
      {sublist, index}, map when is_list(sublist) ->
        Map.put(map, index, nested_list_to_nested_map(sublist))
      {item, index}, map -> 
        Map.put(map, index, item)
    end)
  end

  @doc """
  Returns the tensor as a nested list of lists (of lists of lists ..., depending on the order of the Tensor)
  """
  def to_list(tensor) do
    do_to_list(tensor.contents, tensor.dimensions, tensor.identity)
  end

  defp do_to_list(tensor_contents, [dimension | dimensions], identity) when dimension <= 0 do
    []
  end

  defp do_to_list(tensor_contents, [dimension], identity) do
    for x <- 0..dimension-1 do
      Map.get(tensor_contents, x, identity)
    end
  end

  defp do_to_list(tensor_contents, [dimension | dimensions], identity) do
    for x <- 0..dimension-1 do 
      do_to_list(Map.get(tensor_contents, x, %{}), dimensions, identity)
    end
  end

  @doc """
  `lifts` a Tensor up one order, by adding a dimension of size `1` to the start.

  This transforms a length-`n` Vector to a 1×`n` Matrix, a `n`×`m` matrix to a `1`×`n`×`m` 3-order Tensor, etc.
  """
  def lift(tensor) do
    %Tensor{
      identity: tensor.identity, 
      dimensions: [1|tensor.dimensions], 
      contents: %{0 => tensor.contents}
    }
  end

end
