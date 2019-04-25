defmodule Servy.PledgeServer do
  @name __MODULE__

  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start do
    IO.puts("Starting the pledge server...")
    GenServer.start(__MODULE__, [], name: @name)
  end

  # Client

  def clear do
    GenServer.cast(@name, :clear)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged() do
    GenServer.call(@name, :total_pledged)
  end

  # Server Callbacks
  def handle_cast(:clear, _state), do: {:noreply, []}

  def handle_call(:total_pledged, _from, state) do
    response = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {:reply, response, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    new_state = [{name, amount} | Enum.take(state, 2)]
    {:reply, id, new_state}
  end

  defp send_pledge_to_service(_, _) do
    # Does stuff...
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

{:ok, pid} = PledgeServer.start()

send(pid, {:stop, "hammertime"})

IO.inspect(PledgeServer.create_pledge("larry", 10))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))

PledgeServer.clear()

IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges())

# IO.inspect(PledgeServer.total_pledged())
