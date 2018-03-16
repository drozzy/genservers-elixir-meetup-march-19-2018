defmodule MyServer do
  def call(pid, msg) do
    ref = :erlang.monitor(:process, pid)
    send pid, {self(), ref, msg}
    receive do
      {^ref, reply} ->
        :erlang.demonitor(ref, [:flush])
        reply
      {:DOWN, ^ref, :process, ^pid, reason} ->
        :erlang.error(reason)
    after 5000 ->
        :erlang.error(:timeout)
    end
  end
end
