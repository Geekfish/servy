defmodule Servy.FourOhFourCounter do
  @name __MODULE__

  alias Servy.GenericServer

  # Client

  def start() do
    IO.puts("Starting the 404 server...")
    GenericServer.start(__MODULE__, [], @name)
  end

  def bump_count(endpoint) do
    Servy.GenericServer.cast(@name, {:bump_count, endpoint})
  end

  def get_count(endpoint) do
    Servy.GenericServer.call(@name, {:get_count, endpoint})
  end

  def get_counts() do
    Servy.GenericServer.call(@name, :get_counts)
  end

  # Server Callbacks
  def handle_cast({:bump_count, endpoint}, state) do
    state = Map.update(state, endpoint, 1, &(&1 + 1))
    {state, state}
  end

  def handle_call({:get_count, endpoint}, state) do
    count = Map.get(state, endpoint, 0)
    {count, state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end
end
