# Tensor

The Tensor library adds support for Vectors, Matrixes and higher-dimension Tensors to Elixir.
These data structures allow easier manipulation of multi-dimensional collections of things.

## Vector

A Vector is a one-dimensional collection of elements. It can be viewed as a list with a known length.

It is nicer than a list because:

- retrieving the length happens in O(1)
- reading/writing elements to the list happens in O(log n), as maps are used internally.
- concatenation, etc. is also < O(n), for the same reason.


## Matrix

A Matrix is a two-dimensional collection of elements, with known width and height.

These are highly useful for certain mathematical calculations, but also for e.g. board games.

## Higher-Dimension Tensor

Tensors are implemented using maps internally. This means that read and write access to elements in them is O(log n).

Vectors and Matrixes are also just Tensors, but there are many simple functions that make more sense when used on these data structures, so all of the Vector, Matrix and Tensor modules are existing.

Higher-dimensional Tensors can be created, but many simple functions are only useful on Vectors and Matrixes. Therefore, these have their own modules. 

Only the values that differ from the __identity__ (defaults to `nil`) are actually stored in the Vector/Matrix/Tensor. This allows for smaller data sizes.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tensor` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:tensor, "~> 0.1.0"}]
    end
    ```

  2. Ensure `tensor` is started before your application:

    ```elixir
    def application do
      [applications: [:tensor]]
    end
    ```

