defmodule Matrix do
  defmodule Inspect do
    @doc false
    def inspect(matrix, _opts) do
      """
      #Matrix<(#{Tensor.Inspect.dimension_string(matrix)})
      #{inspect_contents(matrix)}
      >
      """
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
      top_row_length = String.length(List.first(contents_inspect) || "")
      bottom_row_length = String.length(List.last(contents_inspect) || "")
      top = "┌#{String.pad_trailing("", top_row_length)}┐\n│"
      bottom = "│\n└#{String.pad_trailing("", bottom_row_length)}┘"
      contents_str = contents_inspect |> Enum.join("│\n│")
      "#{top}#{contents_str}#{bottom}"
    end
  end

  @doc """
  Creates a new matrix of dimensions `height` x `width`.

  Optionally pass in a fourth argument, which will be the default values the matrix will be filled with. (default: `0`)
  """
  def new(list_of_lists \\ [], height, width, identity \\ 0) when width >= 0 and height >= 0 and (width > 0 or height > 0) do
    Tensor.new(list_of_lists, [height, width], identity)
  end

  @doc """
  Creates an 'identity' matrix.

  This is a square matrix of size `size` that has the `diag_identity` value (default: `1`) at the diagonal, and the rest is `0`.
  Optionally pass in a third argument, which is the value the rest of the elements in the matrix will be set to.
  """
  def identity_matrix(diag_identity \\ 1, size, rest_identity \\ 0) when size > 0 do
    elems = Stream.cycle([diag_identity]) |> Enum.take(size)
    diag(elems, rest_identity)
  end

  @doc """
  Creates a square matrix where the diagonal elements are filled with the elements of the given List or Vector.
  The second argument is an optional `identity` to be used for all elements not part of the diagonal.
  """
  def diag(list_or_vector, identity \\ 0)

  def diag(vector = %Tensor{dimensions: [_length]}, identity) do
    diag(Tensor.to_list(vector), identity)
  end

  def diag(list = [_|_], identity) when is_list(list) do
    size = length(list)
    matrix = new([], size, size, identity)
    list
    |> Enum.with_index
    |> Enum.reduce(matrix, fn {e, i}, mat -> 
      put_in(mat, [i,i], e)
    end)
  end

  @doc """ 
  True if the matrix is square and the same as its transpose.
  """
  def symmetric?(matrix = %Tensor{dimensions: [s,s]}) do
    matrix == matrix |> transpose
  end
  def symmetric?(%Tensor{dimensions: [_,_]}), do: false

  def square?(%Tensor{dimensions: [s,s]}), do: true
  def square?(%Tensor{dimensions: [_,_]}), do: false

  @doc """
  Returns the `width` of the matrix.
  """
  def width(%Tensor{dimensions: [_height, width]}), do: width
  @doc """
  Returns the `height` of the matrix.
  """
  def height(%Tensor{dimensions: [height, _width]}), do: height

  def transpose(matrix = %Tensor{dimensions: [_,_]}) do
    Tensor.transpose(matrix, 1)
    # new_contents = Enum.reduce(matrix.contents, %{}, fn {row_key, row_map}, new_row_map -> 
    #   Enum.reduce(row_map, new_row_map, fn {col_key, value}, new_row_map ->
    #     map = Map.put_new(new_row_map, col_key, %{})
    #     put_in(map, [col_key, row_key], value)
    #   end)
    # end)
    # %Tensor{identity: matrix.identity, contents: new_contents, dimensions: [h, w]}
  end

  @doc """
  Takes a vector, and returns a 1×`n` matrix.
  """
  def row_matrix(vector = %Tensor{dimensions: [_]}) do
    Tensor.lift(vector)
  end

  @doc """
  """
  def column_matrix(vector = %Tensor{dimensions: [_]}) do
    vector
    |> Tensor.lift
    |> Matrix.transpose
  end

  @doc """
  Returns the rows of this matrix as a list of Vectors.
  """
  def rows(matrix = %Tensor{dimensions: [_w,_h]}) do
    Tensor.slices(matrix)
  end

  @doc """
  Builds a Matrix up from a list of vectors.

  Will only work as long as the vectors have the same length.
  """
  def from_rows(list_of_vectors) do
    Tensor.from_slices(list_of_vectors)
  end

  @doc """
  Returns the columns of this matrix as a list of Vectors.
  """
  def columns(matrix = %Tensor{dimensions: [_,_]}) do
    matrix
    |> transpose
    |> rows
  end

  @doc """
  Returns the `n`-th row of the matrix as a Vector.

  This is the same as doing matrix[n]
  """
  def row(matrix, n) do
    matrix[n]
  end

  @doc """
  Returns the `n`-th column of the matrix as a Vector.

  If you're doing a lot of calls to `column`, consider transposing the matrix 
  and calling `rows` on that transposed matrix, as it will be faster.
  """
  def column(matrix, n) do
    transpose(matrix)[n]
  end

  @doc """
  Returns the values in the main diagonal (top left to bottom right) as list
  """
  def main_diagonal(matrix = %Tensor{dimensions: [h,w]}) do
    for i <- 0..min(w,h)-1 do
      matrix[i][i]
    end
  end

  def flip_vertical(matrix = %Tensor{dimensions: [_w, h]}) do
    new_contents = 
      for {r, v} <- matrix.contents, into: %{} do
        {h-1 - r, v}
      end
    %Tensor{matrix | contents: new_contents}
  end

  def flip_horizontal(matrix) do
    matrix
    |> transpose
    |> flip_vertical
    |> transpose
  end

  def rotate_counterclockwise(matrix) do
    matrix
    |> transpose
    |> flip_vertical
  end

  def rotate_clockwise(matrix) do
    matrix
    |> flip_vertical
    |> transpose
  end

  def rotate_180(matrix) do
    matrix
    |> flip_vertical
    |> flip_horizontal
  end


  @doc """
  Returns the sum of the main diagonal of a square matrix.

  Note that this method will fail when called with a non-square matrix
  """
  def trace(matrix = %Tensor{dimensions: [n,n]}) do
    Enum.sum(main_diagonal(matrix))
  end

  def trace(%Tensor{dimensions: [_,_]}) do
    raise Tensor.ArithmeticError, "Matrix.trace/1 is not defined for non-square matrices!"
  end


  @doc """
  Returns the current identity of matrix  `matrix`.
  """
  defdelegate identity(matrix), to: Tensor

  @doc """
  `true` if `a` is a Matrix.
  """
  defdelegate matrix?(a), to: Tensor

  @doc """
  Returns the element at `index` from `matrix`.
  """
  defdelegate fetch(matrix, index), to: Tensor

  @doc """
  Returns the element at `index` from `matrix`. If `index` is out of bounds, returns `default`.
  """
  defdelegate get(matrix, index, default), to: Tensor
  defdelegate pop(matrix, index, default), to: Tensor
  defdelegate get_and_update(matrix, index, function), to: Tensor

  defdelegate merge_with_index(matrix_a, matrix_b, function), to: Tensor
  defdelegate merge(matrix_a, matrix_b, function), to: Tensor

  defdelegate to_list(matrix), to: Tensor
  defdelegate lift(matrix), to: Tensor

  defdelegate map(matrix, function), to: Tensor
  defdelegate with_coordinates(matrix), to: Tensor
  defdelegate sparse_map_with_coordinates(matrix, function), to: Tensor
  defdelegate dense_map_with_coordinates(matrix, function), to: Tensor
  defdelegate to_sparse_map(matrix), to: Tensor

  @doc """
  Converts a sparse map where each key is a [height, width] coordinate list,
  and each value is anything to a Matrix with the given height, width and contents.

  See `to_sparse_map/1` for the inverse operation.
  """
  def from_sparse_map(matrix, height, width, identity \\ 0) do
    Tensor.from_sparse_map(matrix, [height, width], identity)
  end


  defdelegate add(a, b), to: Tensor
  defdelegate sub(a, b), to: Tensor
  defdelegate mul(a, b), to: Tensor
  defdelegate div(a, b), to: Tensor

  defdelegate add_number(a, b), to: Tensor
  defdelegate sub_number(a, b), to: Tensor
  defdelegate mul_number(a, b), to: Tensor
  defdelegate div_number(a, b), to: Tensor

  @doc """
  Elementwise addition of matrixs `matrix_a` and `matrix_b`.
  """
  defdelegate add_matrix(matrix_a, matrix_b), to: Tensor, as: :add_tensor

  @doc """
  Elementwise subtraction of `matrix_b` from `matrix_a`.
  """
  defdelegate sub_matrix(matrix_a, matrix_b), to: Tensor, as: :sub_tensor

  @doc """
  Elementwise multiplication of `matrix_a` with `matrix_b`.
  """
  defdelegate mul_matrix(matrix_a, matrix_b), to: Tensor, as: :mul_tensor

  @doc """
  Elementwise division of `matrix_a` and `matrix_b`.
  Make sure that the identity of `matrix_b` isn't 0 before doing this. 
  """
  defdelegate div_matrix(matrix_a, matrix_b), to: Tensor, as: :div_tensor

  @doc """
  Calculates the Matrix Product. This is a new matrix, obtained by multiplying
  taking the `m` rows of the `m_by_n_matrix`, the `p` columns of the `n_by_p_matrix`
  and calculating the dot-product (See `Vector.dot_product/2`) of these two `n`-length vectors.
  The resulting values are stored at position [m][p] in the final matrix.

  There is no way to perform this operation in a sparse way, so it is performed dense.
  The identities of the two matrices cannot be kept; `nil` is used as identity of the output Matrix.
  """
  def product(m_by_n_matrix, n_by_p_matrix)
  def product(a = %Tensor{dimensions: [m,n]}, b = %Tensor{dimensions: [n,p]}) do
    b_t = transpose(b)
    list_of_lists = 
      for r <- (0..m-1) do
        for c <- (0..p-1) do
          Vector.dot_product(a[r], b_t[c])
        end
      end
    Tensor.new(list_of_lists, [m, p])
  end



  def product(_a = %Tensor{dimensions: [_,_]}, _b = %Tensor{dimensions: [_,_]}) do
    raise Tensor.ArithmeticError, "Cannot compute Matrix.product if the width of matrix `a` does not match the height of matrix `b`!"
  end

  @doc """
  Calculates the product of `matrix` with `matrix`, `exponent` times.
  If `exponent` == 0, then the result will be the identity matrix with the same dimensions as the given matrix. 

  This is calculated using the fast [exponentiation by squaring](https://en.wikipedia.org/wiki/Exponentiation_by_squaring) algorithm.
  """
  def power(matrix, exponent)

  def power(matrix = %Tensor{dimensions: [a,a]}, negative_number) when negative_number < 0 do
    product(Matrix.identity_matrix(-1, a), power(matrix, -negative_number))
  end

  def power(%Tensor{dimensions: [a,a]}, 0), do: Matrix.identity_matrix(a)
  def power(matrix = %Tensor{dimensions: [a,a]}, 1), do: matrix
  
  def power(matrix = %Tensor{dimensions: [a,a]}, exponent) when rem(exponent, 2) == 0 do
    power(product(matrix, matrix), Kernel.div(exponent, 2))
  end

  def power(matrix = %Tensor{dimensions: [a,a]}, exponent) when rem(exponent, 2) == 1 do
    product(matrix, power(product(matrix, matrix), Kernel.div(exponent, 2)))
  end

  def power(%Tensor{dimensions: [_,_]}) do
    raise Tensor.ArithmeticError, "Cannot compute Matrix.power with non-square matrices"
  end


end

