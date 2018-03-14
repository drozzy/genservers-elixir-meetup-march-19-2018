defmodule Dolphins do
  def dolphin1() do
    receive do
      :do_a_flip -> IO.puts("How about no?")
      :fish -> IO.puts("So long and thanks for all the fish!")
      _ -> IO.puts("Heh, we're smarter than you humans.")
    end
  end
end
