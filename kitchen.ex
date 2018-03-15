defmodule Kitchen do
  def fridge1() do
    receive do
      {from, {:store, food}} ->
        send from, {self(), :ok}
        fridge1()
      {from, {:take, _food}} ->
        # What???
        send from, {self(), :not_found}
        fridge1()
      :terminate -> :ok
    end
  end

  def fridge2(food_list) do
    receive do
      {from, {:store, food}} ->
        send from, {self(), :ok}
        fridge2([food | food_list])
      {from, {:take, food}} ->
        case Enum.member?(food_list, food) do
          true ->
            send from, {self(), {:ok, food}}
            fridge2(List.delete(food_list, food))
          false ->
            send from, {self(), :not_found}
            fridge2(food_list)
        end
      :terminate -> :ok
    end
  end
end
