defmodule MatrixTest do
  use ExUnit.Case
  doctest Matrix

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Inspect" do
    matrix = Tensor.new([[1,2],[3,4]], [2,2])
    assert Inspect.inspect(matrix, []) == """
    #Matrix-(2×2)
    ┌                 ┐
    │       1,       2│
    │       3,       4│
    └                 ┘
    """
  end

  test "transpose |> transpose is the same as original" do
    matrix = Tensor.new([[1,2],[3,4]], [2,2])
    assert matrix |> Matrix.transpose |> Matrix.transpose == matrix

  end

  test "Scalar Addition" do
    matrix = Tensor.new([[1,2],[3,4]], [2,2])
    result = Tensor.new([[3,4],[5,6]], [2,2], 2)

    assert Matrix.add(matrix, 2) == result
  end

  test "Matrix Multiplication" do 
    m1 = Tensor.new([[2,3,4],[1,0,0]], [2,3])
    m2 = Tensor.new([[0,1000],[1,100],[0,10]], [3,2])
    assert Matrix.mult(m1, m2) |> inspect == """
    #Matrix-(2×2)
    ┌                 ┐
    │       3,    2340│
    │       0,    1000│
    └                 ┘
    """
  end
end
