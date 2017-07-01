defmodule TensorTest do
  use ExUnit.Case
  use Tensor
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

  test "merging tensors only works when same dimensions" do
    prefixes = Tensor.new(["foo", "bar"], [2], "")
    postfixes = Tensor.new(["baz"], [1], "")
    assert_raise(Tensor.DimensionsDoNotMatchError, fn -> Tensor.merge(prefixes, postfixes, fn a, b -> a <> b end) end)
  end

  test "Tensor.add_tensor" do
    mat = Matrix.new([[1,2],[3,4]], 2, 2)
    mat2 = Matrix.new([[1,1],[1,1]], 2, 2)
    assert Tensor.add_tensor(mat, mat2) == Matrix.new([[2,3],[4,5]], 2, 2)
  end

  test "Tensor.sub_tensor" do
    mat = Matrix.new([[1,2],[3,4]], 2, 2)
    mat2 = Matrix.new([[1,1],[1,1]], 2, 2)
    assert Tensor.sub_tensor(mat, mat2) == Matrix.new([[0,1],[2,3]], 2, 2)
  end

  test "Tensor.mult_tensor" do
    mat = Matrix.new([[1,2],[3,4]], 2, 2)
    assert Tensor.mult_tensor(mat, mat) == Matrix.new([[1,4],[9,16]], 2, 2)
  end

  test "Tensor.div_tensor" do
    mat = Matrix.new([[1,2],[3,4]], 2, 2, 1)
    assert Tensor.div_tensor(mat, mat) == Matrix.new([[1.0,1.0],[1.0,1.0]], 2, 2, 1.0)
  end




  test "map changes identity" do
    mat = Matrix.new([[1,2],[3,4]],2,2,3)
    mat2 = Tensor.map(mat, fn x -> x*x end)
    assert mat2.identity == 9
  end

  test "map removes values that have new identity" do
    mat = Matrix.new([[1,2],[3,4]],2,2,3)
    mat2 = Tensor.map(mat, fn x -> x*x end)
    assert mat2.contents == %{0 => %{0 => 1, 1 => 4}, 1 => %{1 => 16}}

    mat2b = Tensor.map(mat, fn _x -> 1 end)
    assert mat2b.identity == 1
    assert mat2b.contents == %{0 => %{}, 1 => %{}}

  end

  test "sparse_map_with_coordinates changes identity" do
    mat = Matrix.new([[1,2],[3,4]],2,2,3)
    mat2 = Tensor.sparse_map_with_coordinates(mat, fn {_coords, x} -> x*x end)
    assert mat2.identity == 9
  end

  test "sparse_map_with_coordinates removes values that have new identity" do
    mat = Matrix.new([[1,2],[3,4]],2,2,3)
    mat2 = Tensor.sparse_map_with_coordinates(mat, fn {_coords, x} -> x*x end)
    assert mat2.contents == %{0 => %{0 => 1, 1 => 4}, 1 => %{1 => 16}}

    mat2b = Tensor.sparse_map_with_coordinates(mat, fn {_coords, _x} -> 1 end)
    assert mat2b.identity == 1
    assert mat2b.contents == %{0 => %{}, 1 => %{}}

  end

  test "Extractable vector" do
    x = Vector.new([1,2,3,4])
    {:ok, {item, x}} = Extractable.extract(x)
    assert item == 4
    {:ok, {item, x}} = Extractable.extract(x)
    assert item == 3
    {:ok, {item, x}} = Extractable.extract(x)
    assert item == 2
    {:ok, {item, x}} = Extractable.extract(x)
    assert item == 1
    assert Extractable.extract(x) == {:error, :empty}
  end

  test "Extractable matrix" do
    x = Matrix.new([[1,2],[3,4]], 2, 2)
    {:ok, {item, x}} = Extractable.extract(x)
    assert item == Vector.new([3,4])
    {:ok, {item, x}} = Extractable.extract(x)
    assert item == Vector.new([1,2])
    assert Extractable.extract(x) == {:error, :empty}
  end

  test "Insertable vector" do
    x = Vector.new()
    {:ok, x} = Insertable.insert(x, 10)
    {:ok, x} = Insertable.insert(x, 20)
    {:ok, x} = Insertable.insert(x, 30)
    assert x == Vector.new([10, 20, 30])
  end

  test "Insertable matrix" do
    x = Matrix.new(0, 2)
    {:ok, x} = Insertable.insert(x, Vector.new([1, 2]))
    {:ok, x} = Insertable.insert(x, Vector.new([3, 4]))
    assert x == Matrix.new([[1,2],[3,4]], 2, 2)
  end

  test "Reducable vector" do
    x = Vector.new([1,2,3,4])
    assert FunLand.Reducable.reduce(x, 0, fn x, acc -> acc + x end) == 10
  end
end
