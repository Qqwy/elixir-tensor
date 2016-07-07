defmodule Matrix do
  defmodule Inspect do
    @doc false
    def inspect(matrix, _opts) do
      "#Matrix-(#{matrix.dimensions |> Enum.join("×")})#{inspect_contents(matrix)}"
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
      top = "\n┌#{String.pad_trailing("", top_row_length)}┐\n│"
      bottom = "│\n└#{String.pad_trailing("", bottom_row_length)}┘\n"
      contents_str = contents_inspect |> Enum.join("│\n│")
      "#{top}#{contents_str}#{bottom}"
    end
  end

  @doc """
  Creates a new matrix of dimensions `width` x `height`.

  Optionally pass in a fourth argument, which will be the default values the matrix will be filled with. (default: `0`)
  """
  def new(list_of_lists \\ [], width, height, identity \\ 0) when width >= 0 and height >= 0 and (width > 0 or height > 0) do
    contents = list_of_lists_to_matrix_map(list_of_lists)
    %Tensor{identity: identity, dimensions: [width, height], contents: contents}
  end

  # TODO: Generalize this to tensors?
  defp list_of_lists_to_matrix_map(list_of_lists) do
    list_of_lists
    |> Enum.with_index
    |> Enum.reduce(%{}, fn {row_list, i}, map -> 
      row_list
      |> Enum.with_index
      |> Enum.reduce(map, fn {value, j}, map -> 
        map = Map.put_new(map, i, %{})
        put_in(map, [i,j], value)
      end)
    end)
  end

  @doc """
  Converts a matrix to a list of lists.
  """
  def to_list(matrix) do
    Tensor.to_list(matrix)
  end

  @doc """
  Creates an 'identity' matrix.

  This is a square matrix of size `size` that has the `diag_identity` value (default: `1`) at the diagonal, and the rest is `0`.
  Optionally pass in a third argument, which is the value the rest of the elements in the matrix will be set to.
  """
  def identity(diag_identity \\ 1, size, rest_identity \\ 0) when size > 0 do
    elems = Stream.cycle([diag_identity]) |> Enum.take(size)
    diag(elems, rest_identity)
  end

  @doc """
  Creates a square matrix where the diagonal elements are filled with the elements of `list`.
  The second argument is an optional `identity` to be used for all elements not part of the diagonal.
  """
  def diag(list = [_|_], identity \\ 0) when is_list(list) do
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


  # Scalar addition
  def add(matrix, num) when is_number(num) do 
    Tensor.add_number(matrix, num)
  end

  @doc """
  Calculates the Scalar Multiplication or Matrix Multiplication of `a` * `b`.

  If `b` is a number, then a new matrix where all values will be multiplied by `b` are returned.

  if `b` is a matrix, then Matrix Multiplication is performed.

  This will only work as long as the height of `a` is the same as the width of `b`.

  This operation internally builds up a list-of-lists, and finally transforms that back to a matrix.
  """
  # Scalar multiplication
  def mult(matrix, num) when is_number(num) do 
    Tensor.map(matrix, fn val -> val * num end)
  end

  # Matrix multiplication
  # TODO: What to do with identity?
  def mult(a = %Tensor{dimensions: [m,n]}, b = %Tensor{dimensions: [n,p]}) do
    b_t = transpose(b)
    list_of_lists = 
      for r <- (0..m-1) do
        for c <- (0..p-1) do
          Vector.dot_product(a[r], b_t[c])
        end
      end
    Tensor.new(list_of_lists, [m, p])
  end


  def mult(_a = %Tensor{dimensions: [_,_]}, _b = %Tensor{dimensions: [_,_]}) do
    raise Tensor.ArithmeticError, "Cannot compute dot product if the width of matrix `a` does not match the height of matrix `b`!"
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

end

