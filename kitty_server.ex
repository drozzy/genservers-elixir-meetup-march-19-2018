defmodule KittyServer do
  defmodule Cat do
    defstruct name: nil, color: :green, description: nil
  end

  ### Client API
  def start_link() do
    spawn_link(&init/0)
  end

  ## Synchronous call
  def order_cat(pid, name, color, description) do
    MyServer.call pid, {:order, name, color, description}
  end

  ## Asynchronous call
  def return_cat(pid, %Cat{}=cat) do
    send pid, {:return, cat}
    :ok
  end

  ## Synchronous call
  def close_shop(pid) do
    MyServer.call pid, :terminate
  end

  ### Server functions
  defp init() do
    loop([])
  end

  defp loop(cats) do
    receive do
      {pid, ref, {:order, name, color, description}} ->
        cond do
          cats === [] ->
            # No cats left - go make one!
            send pid, {ref, make_cat(name, color, description)}
            loop(cats)
          cats !== [] ->
            # Take a random one from the stock instead.
            send pid, {ref, hd(cats)}
            loop(tl(cats))
        end
      {:return, %Cat{}=cat} ->
        loop([cat|cats])
      {pid, ref, :terminate} ->
        send pid, {ref, :ok}
        terminate(cats)
      unknown ->
        IO.puts("Unknown message: #{inspect unknown}")
        loop(cats)
    end
  end

  ### Private/helper functions
  defp make_cat(name, col, desc) do
    %Cat{name: name, color: col, description: desc}
  end

  defp terminate(cats) do
    for c <- cats, do: IO.puts("#{inspect c.name} was set free.")
    :ok
  end
end
