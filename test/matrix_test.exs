defmodule MatrixTest do
  use ExUnit.Case
  doctest Matrix

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Inspect" do
    matrix = Matrix.new([[1,2],[3,4]], 2,2)
    assert Inspect.inspect(matrix, []) == """
    #Matrix-(2×2)
    ┌                 ┐
    │       1,       2│
    │       3,       4│
    └                 ┘
    """
  end

  test "identity_matrix" do
    inspect Matrix.identity_matrix(3) =="""
    #Matrix-(3×3)
    ┌                          ┐
    │       1,       0,       0│
    │       0,       1,       0│
    │       0,       0,       1│
    └                          ┘
    """
  end

  test "transpose |> transpose is the same as original" do
    matrix = Matrix.new([[1,2],[3,4]], 2,2)
    assert matrix |> Matrix.transpose |> Matrix.transpose == matrix
  end

  test "Scalar Addition" do
    matrix = Matrix.new([[1,2],[3,4]], 2,2)
    result = Matrix.new([[3,4],[5,6]], 2,2, 2)

    assert Matrix.add(matrix, 2) == result
  end

  test "scalar addition is commutative with transposition" do
    matrix = Matrix.new([[1,2],[3,4]], 2,2)

    assert matrix |> Matrix.transpose |> Matrix.add(2) == matrix |> Matrix.add(2) |> Matrix.transpose
  end

  test "Matrix Multiplication" do 
    m1 = Matrix.new([[2,3,4],[1,0,0]], 2,3)
    m2 = Matrix.new([[0,1000],[1,100],[0,10]], 3,2)
    assert Matrix.product(m1, m2) |> inspect == """
    #Matrix-(2×2)
    ┌                 ┐
    │       3,    2340│
    │       0,    1000│
    └                 ┘
    """
  end

  test "matrix productiplication with the identity matrix results in same matrix" do
    m1 = Matrix.new([[2,3,4],[1,0,0]], 2,3)
    mid = Matrix.identity_matrix(3)

    assert Matrix.product(m1, mid) == m1
  end


  test "chess" do

    board_as_list = 
    [
      ["♜","♞","♝","♛","♚","♝","♞","♜"],
      ["♟","♟","♟","♟","♟","♟","♟","♟"],
      [" "," "," "," "," "," "," "," "],
      [" "," "," "," "," "," "," "," "],
      [" "," "," "," "," "," "," "," "],
      [" "," "," "," "," "," "," "," "],
      ["♙","♙","♙","♙","♙","♙","♙","♙"],
      ["♖","♘","♗","♕","♔","♗","♘","♖"]
    ]
    matrix = Matrix.new(board_as_list, 8,8)
    assert inspect(matrix) == 
    """
    #Matrix-(8×8)
    ┌                                                                       ┐
    │     "♜",     "♞",     "♝",     "♛",     "♚",     "♝",     "♞",     "♜"│
    │     "♟",     "♟",     "♟",     "♟",     "♟",     "♟",     "♟",     "♟"│
    │     " ",     " ",     " ",     " ",     " ",     " ",     " ",     " "│
    │     " ",     " ",     " ",     " ",     " ",     " ",     " ",     " "│
    │     " ",     " ",     " ",     " ",     " ",     " ",     " ",     " "│
    │     " ",     " ",     " ",     " ",     " ",     " ",     " ",     " "│
    │     "♙",     "♙",     "♙",     "♙",     "♙",     "♙",     "♙",     "♙"│
    │     "♖",     "♘",     "♗",     "♕",     "♔",     "♗",     "♘",     "♖"│
    └                                                                       ┘
    """

  end

end
