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
end
