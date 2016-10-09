# Tensor

[![hex.pm version](https://img.shields.io/hexpm/v/tensor.svg)](https://hex.pm/packages/tensor)

The Tensor library adds support for Vectors, Matrixes and higher-dimension Tensors to Elixir.
These data structures allow easier creation and manipulation of multi-dimensional collections of things.
One could use them for math, but also to build e.g. board game representations.

The Tensor library builds them in a sparse way.


## Vector

A Vector is a one-dimensional collection of elements. It can be viewed as a list with a known length.

```#elixir
iex> vec = Vector.new([1,2,3,4,5])
#Vector-(5)[1, 2, 3, 4, 5]
iex> vec2 = Vector.new(~w{foo bar baz qux})
#Vector-(4)["foo", "bar", "baz", "qux"]
iex> vec2[2]
"baz"
iex> Vector.add(vec, 3)
#Vector-(5)[4, 5, 6, 7, 8]
iex> Vector.add(vec, vec)
#Vector-(5)[2, 4, 6, 8, 10]
```

It is nicer than a list because:

  - retrieving the length happens in O(1)
  - reading/writing elements to the list happens in O(log n), as maps are used internally.
  - concatenation, etc. is also < O(n), for the same reason.

Vectors are very cool, so the following things have been defined to make working with them a bliss:

  - creating vectors from lists
  - appending values to vectors
  - reverse a vector

When working with numerical vectors, you might also like to:
  
  - addition of a number to all elements in a vector.
  - elementwise addition of two vectors of the same size. 
  - calculate the dot product of two numerical vectors


## Matrix

A Matrix is a two-dimensional collection of elements, with known width and height.

These are highly useful for certain mathematical calculations, but also for e.g. board games.

Matrices are super useful, so there are many helper methods defined to work with them.

```#elixir

iex> mat = Matrix.new([[1,2,3],[4,5,6],[7,8,9]],3,3)
#Matrix-(3×3)
┌                          ┐
│       1,       2,       3│
│       4,       5,       6│
│       7,       8,       9│
└                          ┘
iex> Matrix.rotate_clockwise(mat)
#Matrix-(3×3)
┌                          ┐
│       7,       4,       1│
│       8,       5,       2│
│       9,       6,       3│
└                          ┘
iex> mat[0]
#Vector-(3)[1, 2, 3]
iex> mat[2][2]
9
iex> Matrix.diag([1,2,3])
#Matrix-(3×3)
┌                          ┐
│       1,       0,       0│
│       0,       2,       0│
│       0,       0,       3│
└                          ┘

iex> Matrix.add(mat, 2)
#Matrix-(3×3)
┌                          ┐
│       3,       4,       5│
│       6,       7,       8│
│       9,      10,      11│
└                          ┘
iex> Matrix.add(mat, mat)
Matrix.add(mat, mat)
#Matrix-(3×3)
┌                          ┐
│       2,       4,       6│
│       8,      10,      12│
│      14,      16,      18│
└                          ┘

```

The Matrix module lets you:

  - creating matrices from lists
  - creating an identity matrix
  - creating a diagonal matrix from a list.
  - Transpose matrices.
  - Rotate and flip matrices.
  - Check if a matrix is `square?`, `diagonal?`, or `symmetric?`.
  - creating row- or column matrices from vectors.
  - extract specific rows or columns from a matrix.
  - extract values from the main diagonal.


As well as some common math operations

  - Add a number to all values inside a matrix
  - Multiply all values inside a matrix with a number
  - Matrix Multiplication, with two matrices.
  - the `trace` operation for square matrices.


## Higher-Dimension Tensor

Tensors are implemented using maps internally. This means that read and write access to elements in them is O(log n).

```#elixir
iex> tensor = Tensor.new([[[1,2],[3,4],[5,6]],[[7,8],[9,10],[11,12]]], [3,3,2])
#Tensor(3×3×2)
       1,       2
         3,       4
           5,       6
       7,       8
         9,      10
          11,      12
       0,       0
         0,       0
           0,       0
iex> tensor[1]
#Matrix-(3×2)
┌                 ┐
│       7,       8│
│       9,      10│
│      11,      12│
└                 ┘


```

Vector and Matrices are also Tensors. There exist some functions that only make sense when used on these one- or two-dimensional structures. Therefore, the extra Vector and Matrix modules exist.

## Sparcity

The Vectors/Matrices/Tensors are stored in a *sparse* way. 
Only the values that differ from the __identity__ (defaults to `nil`) are actually stored in the Vector/Matrix/Tensor. 

This allows for smaller data sizes, as well as faster operations when peforming on, for instance, diagonal matrices.

## Syntactic Sugar

For Tensors, many sugary protocols and behaviours have been implemented to let them play nicely with other parts of your applications:

### Access Behaviour

Tensors have implementations of the Access Behaviour, which let you do:

    iex> require Tensor
    iex> mat = Matrix.new([[1,2],[3,4]], 2,2)
    iex> mat[0]
    #Vector-(2)[1, 2]
    iex> mat[1][1]
    4
    iex> put_in mat[1][0], 100
    #Matrix-(2×2)
    ┌                 ┐
    │       1,       2│
    │     100,       4│
    └                 ┘

It is even possible to use negative indices to look from the end of the Vector/Matrix/Tensor!

### Enumerable Protocol

Tensors allow you to enumerate over the values inside, using the Enumerable protocol.
Note that:

- enumerating over a Vector will iterate over the values inside, 
- enumerating over a Matrix will iterate over the Vectors that make up the rows of the matrix
- enumerating over an order-3 Tensor will iterate over the Matrices that make up the 2-dimensional slices of this Tensor,
- *etc...*

As there are many other ways to iterate over values inside tensors, functions like `Tensor.to_list` , `Matrix.columns` also exist.

There are also functions like `Tensor.map`, which returns a new Tensor containg the results of this mapping operation. `Tensor.map` is nice in the way that it will only iterate over the
actual values that have a value other than the default, which makes it fast.


If you can think of other nice ways to enumerate over Tensors, please let me know, as these would make great additions to the library!


### Collectable Protocol

If you want to build up a Vector from a collection of values, or a Matrix from a collection of Vectors, (or an order-3 tensor from a collection of Matrices, etc), you can do so by harnessing the power of the Collectable protocol.

    iex> mat = Matrix.new(0,3)
    iex> v = Vector.new([1,2,3])
    iex> Enum.into([v,v,v], mat)
    #Matrix-(3×3)
    ┌                          ┐
    │       1,       2,       3│
    │       1,       2,       3│
    │       1,       2,       3│
    └                          ┘

### Inspect Protocol

The Inspect protocol has been overridden for all Tensors.

- Vectors are shown as a list with the length given.
- Matrices are shown in a two-dimensional grid, with the dimensions given.
- Three-dimensional tensors are shown with indentation and colour changes, to show the relationship of the values inside.
- Four-dimensional Tensors and higher print their lower-dimension values from top-to-bottom.



## Installation

The package can be installed by adding `tensor` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:tensor, "~> 0.7.0"}
      ]
    end
    ```

## Roadmap

- [x] Operation to swap any two arbitrary dimensions of a Tensor, a generalized version of `Matrix.transpose`
- [x] Improve Tensor inspect output.
- [x] Move more functionality to Tensor.
- [x] Add Dyalizer specs to all important methods.
- [ ] Add aliases to common methods of Tensor to:
  - [x] Vector
  - [x] Matrix
- [x] Ensure that when the identity value is stored, it is not actually stored in a Tensor, so Tensor is kept sparse.
  - [x] `Tensor.new`
  - [x] `Tensor.map`
  - [x] `Tensor.sparse_map_with_coordinates`
  - [x] `Tensor.dense_map_with_coordinates`
  - [x] `Tensor.merge`
  - [x] `Tensor.merge_with_coordinates`
- [ ] Write (doc)tests for all public functions.
- [ ] Improve documentation.

