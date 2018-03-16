defmodule MyServer do
  def call(pid, msg) do
    ref = :erlang.monitor(:process, pid)
    send pid, {:sync, self(), ref, msg}
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

  def cast(pid, msg) do
    send pid, {:async, msg}
    :ok
  end

  def loop(module, state) do
    receive do
      {:async, msg} ->
        loop(module, module.handle_cast(msg, state))
      {:sync, pid, ref, msg} ->
        loop(module, module.handle_call(msg, pid, ref, state))
    end
  end

end
