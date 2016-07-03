defmodule TensorTest do
  use ExUnit.Case
  doctest Tensor

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "basic construction" do
    matrix = %Tensor{contents: %{0 => %{0 => 1, 1 => 2}, 1 => %{0 => 3, 1 => 4}}, dimensions: [2, 2], identity: nil}
    assert Inspect.inspect(matrix, []) == "#Matrix-(2x2)%{0 => %{0 => 1, 1 => 2}, 1 => %{0 => 3, 1 => 4}}"
  end
end
