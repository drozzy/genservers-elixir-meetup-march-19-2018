defmodule MyServer do
  # Public API of MyServer 
  def start_link(module, initial_state) do
    spawn_link(fn() -> init(module, initial_state) end)
  end

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

  def reply({pid, ref}, reply) do
    send pid, {ref, reply}
  end

  # Private to MyServer
  defp init(module, initial_state) do
    loop(module, module.init(initial_state))
  end

  defp loop(module, state) do
    receive do
      {:async, msg} ->
        loop(module, module.handle_cast(msg, state))
      {:sync, pid, ref, msg} ->
        loop(module, module.handle_call(msg, {pid, ref}, state))
    end
  end

end
