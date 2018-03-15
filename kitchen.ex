defmodule Kitchen do
  def start(food_list) do
    spawn(__MODULE__, :fridge2, [food_list])
  end

  def store(pid, food) do
    send pid, {self(), {:store, food}}
    receive do
      {pid, msg} -> msg
    after 5000 ->
      :timeout
    end
  end

  def take(pid, food) do
    send pid, {self(), {:take, food}}
    receive do
      {pid, msg} -> msg
    after 5000 ->
      :timeout
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
