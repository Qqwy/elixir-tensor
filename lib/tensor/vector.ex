defmodule Tensor.Vector do
  alias Tensor.{Vector, Matrix, Tensor}

  import Kernel, except: [length: 1]
  defmodule Inspect do
    @doc false
    def inspect(vector, _opts) do
      "#Vector<(#{Tensor.Inspect.dimension_string(vector)})#{inspect Vector.to_list(vector)}>"
    end
  end

  def new() do
    Tensor.new([], [0], 0)
  end

  def new(length_or_list_or_range, identity \\ 0)

  def new(list, identity) when is_list(list) do
    Tensor.new(list, [Kernel.length(list)], identity)
  end

  def new(length, identity) when is_number(length) do
    Tensor.new([], [length], identity)
  end

  def new(range = _.._, identity) do
    new(range |> Enum.to_list, identity)
  end

  def length(vector) do
    hd(vector.dimensions)
  end

  def from_list(list, identity \\ 0) do
    Tensor.new(list, [Kernel.length(list)], identity)
  end

  def reverse(vector = %Tensor{dimensions: [l]}) do
    new_contents =
      for {i, v} <- vector.contents, into: %{} do
        {l-1 - i, v}
      end
    %Tensor{vector | contents: new_contents}
  end

  def dot_product(a = %Tensor{dimensions: [l]}, b = %Tensor{dimensions: [l]}) do
    products = 
      for i <- 0..(l-1) do
        a[i] * b[i]
      end
    Enum.sum(products)
  end
  def dot_product(_a, _b), do: raise Tensor.ArithmeticError, "Two Vectors have to have the same length to be able to compute the dot product"


  @doc """
  Returns the current identity of vector  `vector`.
  """
  defdelegate identity(vector), to: Tensor

  @doc """
  `true` if `a` is a Vector.
  """
  defdelegate vector?(a), to: Tensor

  @doc """
  Returns the element at `index` from `vector`.
  """
  defdelegate fetch(vector, index), to: Tensor

  @doc """
  Returns the element at `index` from `vector`. If `index` is out of bounds, returns `default`.
  """
  defdelegate get(vector, index, default), to: Tensor
  defdelegate pop(vector, index, default), to: Tensor
  defdelegate get_and_update(vector, index, function), to: Tensor

  defdelegate merge_with_index(vector_a, vector_b, function), to: Tensor
  defdelegate merge(vector_a, vector_b, function), to: Tensor

  defdelegate to_list(vector), to: Tensor
  defdelegate lift(vector), to: Tensor

  defdelegate map(vector, function), to: Tensor
  defdelegate with_coordinates(vector), to: Tensor
  defdelegate sparse_map_with_coordinates(vector, function), to: Tensor
  defdelegate dense_map_with_coordinates(vector, function), to: Tensor


  defdelegate add(a, b), to: Tensor
  defdelegate sub(a, b), to: Tensor
  defdelegate mult(a, b), to: Tensor
  defdelegate div(a, b), to: Tensor

  defdelegate add_number(a, b), to: Tensor
  defdelegate sub_number(a, b), to: Tensor
  defdelegate mult_number(a, b), to: Tensor
  defdelegate div_number(a, b), to: Tensor

  @doc """
  Elementwise addition of vectors `vector_a` and `vector_b`.
  """
  defdelegate add_vector(vector_a, vector_b), to: Tensor, as: :add_tensor

  @doc """
  Elementwise subtraction of `vector_b` from `vector_a`.
  """
  defdelegate sub_vector(vector_a, vector_b), to: Tensor, as: :sub_tensor

  @doc """
  Elementwise multiplication of `vector_a` with `vector_b`.
  """
  defdelegate mult_vector(vector_a, vector_b), to: Tensor, as: :mult_tensor

  @doc """
  Elementwise division of `vector_a` and `vector_b`.
  Make sure that the identity of `vector_b` isn't 0 before doing this. 
  """
  defdelegate div_vector(vector_a, vector_b), to: Tensor, as: :div_tensor

end
