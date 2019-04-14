defmodule Servy.PledgeServer do
  @name __MODULE__

  # Client

  def start do
    IO.puts("Starting the pledge server...")
    pid = spawn(__MODULE__, :listen_loop, [])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    send(@name, {self(), :create_pledge, name, amount})

    receive do
      {:response, id} -> id
    end
  end

  def recent_pledges() do
    send(@name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged() do
    send(@name, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  # Server

  def listen_loop(state \\ []) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        send(sender, {:response, id})
        new_state = [{name, amount} | Enum.take(state, 2)]
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_, _) do
    # Does stuff...
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
