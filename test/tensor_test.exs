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

    assert Tensor.transpose(t3, 1) == t3_transpose(1)
    assert Tensor.transpose(t3, 2) == t3_transpose(2)
  end

end
