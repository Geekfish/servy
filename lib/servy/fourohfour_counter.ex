defmodule Servy.FourOhFourCounter do
  @name __MODULE__

  # Client

  def start() do
    pid = spawn(__MODULE__, :listen_loop, [])
    Process.register(pid, @name)
    pid
  end

  def bump_count(endpoint) do
    send(@name, {:bump_count, endpoint})
  end

  def get_count(endpoint) do
    send(@name, {self(), :get_count, endpoint})

    receive do
      {:result, count} -> count
    end
  end

  def get_counts() do
    send(@name, {self(), :get_counts})

    receive do
      {:result, state} -> state
    end
  end

  # Server

  def listen_loop(state \\ %{}) do
    receive do
      {:bump_count, endpoint} ->
        state = Map.update(state, endpoint, 1, &(&1 + 1))
        listen_loop(state)

      {sender, :get_count, endpoint} ->
        count = Map.get(state, endpoint, 0)
        send(sender, {:result, count})
        listen_loop(state)

      {sender, :get_counts} ->
        send(sender, {:result, state})
        listen_loop(state)

      _ ->
        listen_loop(state)
    end
  end
end
