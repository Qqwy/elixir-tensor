defmodule ListSwapBench do
  use Benchfella

  @list Enum.to_list(1..1000)

  for list_length <- [2,10,100,1_000] do
    @list_length list_length
    bench "old swap #{@list_length}" do
      Tensor.Helper.swap_elems_in_list(Enum.to_list(1..@list_length), 1, div(@list_length,2))
    end

    bench "new swap #{@list_length}" do
      Tensor.Helper.swap2(Enum.to_list(1..@list_length), 1, div(@list_length,2))
    end

    bench "map swap #{@list_length}" do
      Tensor.Helper.map_swap(Enum.to_list(1..@list_length), 1, div(@list_length,2))
    end
  end



end