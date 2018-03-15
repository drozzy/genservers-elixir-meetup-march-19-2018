defmodule Linkmon do
  def myproc() do
    :timer.sleep(5000)
    exit(:reason)
  end
end
