defmodule Sortv1 do

  @moduledoc """
  Documentation for `Sortv1`.
  """


  def compare_elems([], _count, _direction) do

  end

  def compare_elems(list, count, direction) do
    half = round(count/2)
    {first, second} = Enum.split(list, half)

    {first_part, second_part} = rec(first, second, direction)
    {first_part, second_part}
  end

      @doc """
  Merge values recursively
  """

  def bitonic_merge(list, count, _direction, _threads) when count <= 1 do
    list
  end

  def bitonic_merge(list, count, direction, threads) when count > 1 and threads <2 do
    {first_part, second_part} =  compare_elems(list, count, direction)
		r1 = bitonic_merge(first_part, length(first_part), direction,1);
		r2 = bitonic_merge(second_part, length(second_part), direction,1);

    r1++r2
  end

  def bitonic_merge(list, count, direction, threads) when count > 1 and threads >= 2 do
    {first_part, second_part} =  compare_elems(list, count, direction)
		r1 = Task.async(fn -> bitonic_merge(first_part, length(first_part), direction, threads/2) end);
		r2 = Task.async(fn -> bitonic_merge(second_part, length(second_part), direction, threads/2) end);

    re1 = Task.await(r1, 100000)
    re2 = Task.await(r2, 100000)

    re1++re2
  end

    @doc """
  Devides list on the equal parts and start parralel threads
  """

  def bitonic_sort(list, count, _direction) when count <= 1 do
    list
  end

  def bitonic_sort(list, count, direction) when count > 1 do
    half = round(count/2)
    {first, second} = Enum.split(list, half)
    r1 = bitonic_sort(first,  length(first), true)
		r2 = bitonic_sort(second, length(second), false)

    bitonic_merge( r1++r2 , count, direction, 1)
  end
  @doc """
  Devides list on the equal parts and start parralel threads
  """

  def parralelBitonic(list, count, direction, count_threads ) when count_threads <= 1 do
    bitonic_sort(list, count, direction)
  end

  def parralelBitonic(list, count, direction, count_threads ) when count_threads > 1 do

    half = round(count/2)
    {first, second} = Enum.split(list, half)

    r1 = Task.async(fn -> parralelBitonic(first, length(first), true, count_threads/2) end)
    r2 = Task.async(fn -> parralelBitonic(second, length(second), false, count_threads/2) end)

    re1 = Task.await(r1, 1000000000)
    re2 = Task.await(r2, 1000000000)

    bitonic_merge( re1++re2 , count, direction, count_threads)
  end


  def parralelBitonic(list, threads ) do
    res = parralelBitonic(list, length(list), false, threads)
    res
  end
  @doc """
  Compare to lists each over and changes elements ascending or descending
  from last element compares it, and add elements in the right list and return it
  """

  def rec([],[], _direction) do
    {[],[]}
  end

  def rec([head| tail], [head2|tail2], direction) when (head>head2)!=direction do
    {a,b} = rec(tail, tail2, direction)
    {[head2| a],b++[head]}
  end

  def rec([head| tail], [head2|tail2], direction) when (head>head2)==direction do
    {a,b} = rec(tail, tail2, direction)
    {[head| a],b++[head2]}
  end

  @doc """
  Helper function, just check results of the sorting
  recursively divide list, compare head and previous element and return result
  """
  def check_res([head | tail]) do
    check_res(head, tail)
  end


  def check_res(elem, [head| tail]) when length(tail) > 0 do

    r1 = check_res(head, tail)

    (r1==(head >= elem))
  end

  def check_res(elem, [head| tail]) when length(tail) == 0 do

    head >= elem

  end

end



#================main======================
n = 262144 #8388608
list = 1..n |> Enum.map(fn _ -> Enum.random(1..10000) end)
list = Enum.map(list, fn x -> x/1 end)

# {time_in_microseconds, ret_val} = :timer.tc(fn -> Sortv1.parralelBitonic(list, 1) end)
# IO.puts "1 thread"
# IO.inspect(time_in_microseconds/1000, label: " time in ms")


{time_in_microseconds, ret_val} = :timer.tc(fn -> Sortv1.parralelBitonic(list, 2) end)
# IO.puts "Res"
# IO.inspect(ret_val)
IO.puts "2 thread"
IO.inspect(time_in_microseconds/1000, label: " time in ms")
# check = Sortv1.check_res(ret_val)
# IO.inspect(check)

{time_in_microseconds, ret_val} = :timer.tc(fn -> Sortv1.parralelBitonic(list, 4) end)
# IO.puts "Res"
# IO.inspect(ret_val)
IO.puts "4 thread"
IO.inspect(time_in_microseconds/1000, label: " time in ms")


{time_in_microseconds, ret_val} = :timer.tc(fn -> Sortv1.parralelBitonic(list, 8) end)
# IO.puts "Res"
# IO.inspect(ret_val)
IO.puts "8 thread"
IO.inspect(time_in_microseconds/1000, label: " time in ms")


{time_in_microseconds, ret_val} = :timer.tc(fn -> Sortv1.parralelBitonic(list, 16) end)
# IO.puts "Res"
# IO.inspect(ret_val)
IO.puts "16 thread"
IO.inspect(time_in_microseconds/1000, label: " time in ms")
#============================================
