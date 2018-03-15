defmodule Chef do

  def start_chef() do
    spawn(__MODULE__, :restarter, [])
  end

  def restarter() do
    Process.flag(:trap_exit, true)
    pid = spawn_link(__MODULE__, :chef, [])
    Process.register(pid, :chef)

    receive do
      {:EXIT, pid, :normal} -> # not a crash
        :ok
      {:EXIT, pid, :shutdown} -> # manual shut-down
        :ok
      {:EXIT, pid, _} -> # crash
        restarter()
    end
  end

  def cook(dish, temperature) do
    send :chef, {self(), {dish, temperature}}
    pid = Process.whereis(:chef)
    receive do
      {^pid, response} -> response
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
