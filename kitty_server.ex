defmodule KittyServer do
  use GenServer

  defmodule Cat do
    defstruct name: nil, color: :green, description: nil
  end

  ### Client API
  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  ## Synchronous call
  def order_cat(pid, name, color, description) do
    GenServer.call pid, {:order, name, color, description}
  end

  ## Asynchronous call
  def return_cat(pid, %Cat{}=cat) do
    GenServer.cast pid, {:return ,cat}
  end

  ## Synchronous call
  def close_shop(pid) do
    GenServer.call pid, :terminate
  end

  ### Server functions
  def init([]) do
    {:ok, []}
  end

  def handle_call({:order, name, color, description}, _from, cats) do
      cond do
        cats === [] ->
          # No cats left - go make one!
          {:reply, make_cat(name, color, description), cats}
        cats !== [] ->
          # Take a random one from the stock instead.
          {:reply, hd(cats), tl(cats)}
      end
  end

  def handle_call(:terminate, _from, cats) do
    {:stop, :normal, :ok, cats}
  end

  def handle_cast({:return, %Cat{}=cat}, cats) do
      {:noreply, [cat|cats]}
  end

  def handle_info(msg, cats) do
    IO.puts("Unexpected message: #{inspect msg}")
    {:noreply, cats}
  end

  def terminate(:normal, cats) do
    for c <- cats, do: IO.puts("#{inspect c.name} was set free.")
    :ok
  end

  ### Private/helper functions
  defp make_cat(name, col, desc) do
    %Cat{name: name, color: col, description: desc}
  end

end
