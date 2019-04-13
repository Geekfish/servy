defmodule Timer do
  def remind(task, seconds) do
    sleep_time = seconds * 1000

    spawn(fn ->
      :timer.sleep(sleep_time)
      IO.puts(task)
    end)
  end
end
