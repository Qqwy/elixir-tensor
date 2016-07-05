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

  @opaque tensor :: %Tensor{}

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
    # TODO: Ensure that identity values are not stored.
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

  TODO: Solve this, maybe find a nicer way to create tensors.
  """
  def new(nested_list_of_values, dimensions \\ nil, identity \\ 0) do
    dimensions = dimensions || [length(nested_list_of_values)]
    # TODO: Dimension inference.
    contents = 
      nested_list_of_values
      |> nested_list_to_nested_map
    %Tensor{contents: contents, identity: identity, dimensions: dimensions}
  end


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

  @doc """
  Maps `fun` over all values in the Tensor.

  `fun` gets the current value as input, and should return the new value to use.

  It is important that `fun` is a pure function, as internally it will only be mapped over all values
  that are non-empty, and once over the identity of the tensor.
  """
  @spec map(tensor, (any -> any)) :: tensor
  def map(tensor, fun) do
    new_identity = fun.(tensor.identity)
    new_contents = do_map(tensor.contents, tensor.dimensions, fun)
    %Tensor{tensor | identity: new_identity, contents: new_contents}
  end

  def do_map(tensor_contents, [dimension], fun) do
    for {k,v} <- tensor_contents, into: %{} do
      {k, fun.(v)}
    end
  end

  def do_map(tensor_contents, [dimension|dimensions], fun) do
    for {k,v} <- tensor_contents, into: %{} do
      {k, do_map(v, dimensions, fun)}
    end
  end

  defimpl Enumerable do
    def count(tensor), do: {:ok, Enum.sum(tensor.dimensions)}
  
    def member?(tensor, element), do: {:error, __MODULE__}

    def reduce(tensor, acc, fun) do
      tensor
      |> Tensor.to_list
      |> do_reduce(acc, fun)
    end
  
    defp do_reduce(_,       {:halt, acc}, _fun),   do: {:halted, acc}
    defp do_reduce(list,    {:suspend, acc}, fun), do: {:suspended, acc, &do_reduce(list, &1, fun)}
    defp do_reduce([],      {:cont, acc}, _fun),   do: {:done, acc}
    defp do_reduce([h | t], {:cont, acc}, fun),    do: do_reduce(t, fun.(h, acc), fun)
  end

  defimpl Collectable do
    def into(original ) do
      {original, fn
        # Building a higher-order tensor from lower-order tensors.
        tensor = %Tensor{dimensions: dimensions = [cur_dimension, lower_dimensions]}, 
        {:cont, x = %Tensor{dimensions: x_dimensions}} 
        when length(dimensions) == length(x_dimensions)+1 -> 
          new_dimensions = [cur_dimension+1, lower_dimensions]
          new_contents = put_in(tensor.contents, [cur_dimension], x)
          %Tensor{tensor | dimensions: new_dimensions, contents: new_contents}
        # Inserting values directly into a Vector
        tensor = %Tensor{dimensions: [length]}, {:cont, x} -> 
          new_length = length+1
          new_contents = put_in(tensor.contents, [length], x)
          %Tensor{tensor | dimensions: [new_length], contents: new_contents}
        tensor,  :done -> tensor
        _tensor, :halt -> :ok
      end}
    end
  end

end
