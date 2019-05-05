defmodule Servy.FourOhFourCounter do
  @name __MODULE__

  use GenServer

  # Client

  def start_link(_arg) do
    IO.puts("Starting the 404 server...")
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def bump_count(endpoint) do
    GenServer.cast(@name, {:bump_count, endpoint})
  end

  def get_count(endpoint) do
    GenServer.call(@name, {:get_count, endpoint})
  end

  def get_counts() do
    GenServer.call(@name, :get_counts)
  end

  # Server Callbacks
  def init(_init_arg) do
    {:ok, %{}}
  end

  def handle_cast({:bump_count, endpoint}, state) do
    state = Map.update(state, endpoint, 1, &(&1 + 1))
    {:noreply, state}
  end

  def handle_call({:get_count, endpoint}, state) do
    count = Map.get(state, endpoint, 0)
    {:reply, count, state}
  end

  def handle_call(:get_counts, state) do
    {:reply, state, state}
  end
end
