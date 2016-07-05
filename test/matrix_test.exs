defmodule MatrixTest do
  use ExUnit.Case
  doctest Matrix

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "basic construction" do
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
end
