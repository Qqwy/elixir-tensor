defmodule Matrix do
  defmodule Inspect do
    def inspect(matrix, opts) do
      "#Matrix-(#{matrix.dimensions |> Enum.join("x")})#{inspect matrix.contents}"
    end
  end
end
