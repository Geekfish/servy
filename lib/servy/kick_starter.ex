defmodule Servy.KickStarter do
  use GenServer

  def start do
    IO.puts("Starting the kickstarter...")
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def get_server() do
    GenServer.call(__MODULE__, :get_server)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:ok, start_server()}
  end

  def handle_call(:get_server, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HttpServer exited: #{inspect(reason)}")
    {:noreply, start_server()}
  end

  defp start_server() do
    IO.puts("Starting the HTTP Server")
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)
    server_pid
  end
end
