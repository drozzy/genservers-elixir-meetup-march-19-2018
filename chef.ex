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
    ref = make_ref()
    send :chef, {self(), ref, {dish, temperature}}
    receive do
      {^ref, response} -> response
    after 5000 ->
      :timeout
    end
  end

  def chef() do
    receive do
      {from, ref, {"steak", "rare"}} ->
        send from, {ref, "Excellent choice!"}
      {from, ref, {"steak", _}} ->
        send from, {ref, "Get out of my restaurant!"}
      {from, ref, {"chicken", "rare"}} ->
        send from, {ref, "What is wrong with you?"}
      {from, ref, {"chicken", _}} ->
        send from, {ref, "Coming right up!"}
      {from, ref, {_dish, _temperature}} ->
        send from, {ref, "We don't serve that here."}
    end
    chef()
  end

end
