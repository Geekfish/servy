defmodule Servy.GenericServer do
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [callback_module, initial_state])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(callback_module, state \\ []) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(callback_module, new_state)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(callback_module, new_state)

      unexpected ->
        new_state = callback_module.handle_info(message, state)
        listen_loop(callback_module, new_state)
    end
  end
end

defmodule Servy.PledgeServerHandRolled do
  @name __MODULE__

  alias Servy.GenericServer

  def start do
    IO.puts("Starting the pledge server...")
    GenericServer.start(__MODULE__, [], @name)
  end

  # Client

  def clear do
    GenericServer.cast(@name, :clear)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenericServer.call(@name, :recent_pledges)
  end

  def total_pledged() do
    GenericServer.call(@name, :total_pledged)
  end

  # Server Callbacks
  def handle_cast(:clear, _state), do: []

  def handle_call(:total_pledged, state) do
    response = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {response, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    new_state = [{name, amount} | Enum.take(state, 2)]
    {id, new_state}
  end

  def handle_info(message, state) do
    IO.puts("Unexpected message: #{inspect(message)}")
    state
  end

  defp send_pledge_to_service(_, _) do
    # Does stuff...
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# alias Servy.PledgeServerHandRolled

# pid = PledgeServerHandRolled.start()

# send(pid, {:stop, "hammertime"})

# IO.inspect(PledgeServerHandRolled.create_pledge("larry", 10))
# IO.inspect(PledgeServerHandRolled.create_pledge("moe", 20))
# IO.inspect(PledgeServerHandRolled.create_pledge("curly", 30))
# IO.inspect(PledgeServerHandRolled.create_pledge("daisy", 40))

# PledgeServerHandRolled.clear()

# IO.inspect(PledgeServerHandRolled.create_pledge("grace", 50))

# IO.inspect(PledgeServerHandRolled.recent_pledges())

# IO.inspect(PledgeServerHandRolled.total_pledged())
