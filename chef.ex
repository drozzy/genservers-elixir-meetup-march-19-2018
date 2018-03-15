defmodule Chef do

  def start_chef() do
    spawn(__MODULE__, :chef, [])
  end

  def cook(pid, dish, temperature) do
    send pid, {self(), {dish, temperature}}
    receive do
      {pid, response} -> response
    after 5000 ->
      :timeout
    end
  end

  def chef() do
    receive do
      {from, {"steak", "rare"}} ->
        send from, {self(), "Excellent choice!"}
      {from, {"steak", _}} ->
        send from, {self(), "Get out of my restaurant!"}
      {from, {"chicken", "rare"}} ->
        send from, {self(), "What is wrong with you?"}
      {from, {"chicken", _}} ->
        send from, {self(), "Coming right up!"}
      {from, {_dish, _temperature}} ->
        send from, {self(), "We don't serve that here."}
    end
    chef()
  end

end
