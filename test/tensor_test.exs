defmodule TensorTest do
  use ExUnit.Case
  doctest Tensor

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "transpose" do
    t3 = Tensor.new([[[1,2],[3,4]],[[5,6],[7,8]]], [2,2,2])
    t3_transpose_1 = Tensor.new([[[1,2],[5,6]],[[3,4],[7,8]]], [2,2,2])
    t3_transpose_2 = Tensor.new([[[1,5],[3,7]],[[2,6],[4,8]]], [2,2,2])

    assert Tensor.transpose(t3, 1) == t3_transpose_1
    assert Tensor.transpose(t3, 2) == t3_transpose_2
  end

  test "tensor merge" do
    prefixes = Tensor.new(["foo", "bar"], [2], "")
    postfixes = Tensor.new(["baz", "qux"], [2], "")

    assert Tensor.merge(prefixes, postfixes, fn a, b -> a <> b end) == Tensor.new(["foobaz", "barqux"], [2], "")
  end

  test "elementwise addition" do
    mat = Matrix.new([[1,2],[3,4]], 2, 2)
    mat2 = Matrix.new([[1,1],[1,1]], 2, 2)
    assert Tensor.add_tensor(mat, mat2) == Matrix.new([[2,3],[4,5]], 2, 2)
  end

end
