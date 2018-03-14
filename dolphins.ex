defmodule Dolphins do
  def dolphin1() do
    receive do
      :do_a_flip -> IO.puts("How about no?")
      :fish -> IO.puts("So long and thanks for all the fish!")
      _ -> IO.puts("Heh, we're smarter than you humans.")
    end
  end

  def dolphin2() do
    receive do
      {from, :do_a_flip} -> send from, "How about no?"
      {from, :fish} -> send from, "So long and thanks for all the fish!"
      _ -> IO.puts("Heh, we're smarter than you humans.")
    end
  end
end
