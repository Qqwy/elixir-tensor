# Tensor

The Tensor library adds support for Vectors, Matrixes and higher-dimension Tensors to Elixir.
These data structures allow easier creation and manipulation of multi-dimensional collections of things.
One could use them for math, but also to build e.g. board game representations.

The Tensor library builds them in a sparce way.

## Vector

A Vector is a one-dimensional collection of elements. It can be viewed as a list with a known length.

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

Vectors and Matrixes are also just Tensors, but there are many simple functions that make more sense when used on these data structures, so all of the Vector, Matrix and Tensor modules are existing.

Higher-dimensional Tensors can be created, but many simple functions are only useful on Vectors and Matrixes. Therefore, these have their own modules. 

## Sparcity

The Vectors/Matrices/Tensors are stored in a *sparse* way. 
Only the values that differ from the __identity__ (defaults to `nil`) are actually stored in the Vector/Matrix/Tensor. 

This allows for smaller data sizes, as well as faster operations when peforming on, for instance, diagonal matrices.

## Syntactic Sugar

For Tensors, many niceties have been implemented to let them play nicely with other parts of your applications.

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

As can be seen, the Inspect protocol has been overridden for all Tensors.
This makes it nice to visualize how the Vectors and Matrices look.

*(for higher-order Tensors the inspect representation will probably change. I'm not sure yet how they can best be represented)*



## Installation

The package can be installed by adding `tensor` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:tensor, "~> 0.5.0"}
      ]
    end
    ```

## Roadmap

- [x] Operation to swap any two arbitrary dimensions of a Tensor, a generalized version of `Matrix.transpose`
- [x] Improve Tensor inspect output.
- [ ] Move more functionality to Tensor.
- [ ] Add aliases to common methods of Tensor to Matrix and Vector.
- [ ] Ensure that when the identity value is stored, it is not actually stored in a Tensor, so Tensor is kept sparse.
- [ ] More ways to iterate over vectors/matrices/tensors.
- [ ] Write (doc)tests for all public functions.
- [ ] Improve documentation.
- [ ] Add Dyalizer specs for all methods.

