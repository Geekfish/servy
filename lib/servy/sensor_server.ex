defmodule Servy.SensorServer do
  @name :sensor_server

  defmodule State do
    @default_refresh_interval :timer.seconds(5)
    defstruct sensor_data: %{},
              refresh_interval: @default_refresh_interval
  end

  use GenServer

  # Client Interface

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  # Server Callbacks

  def init(state) do
    initial_state = %{state | sensor_data: run_tasks_to_get_sensor_data()}
    schedule_refresh(initial_state.refresh_interval)
    {:ok, initial_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, state) do
    IO.puts("Refreshing the cache...")
    new_state = %{state | sensor_data: run_tasks_to_get_sensor_data()}
    schedule_refresh(new_state.refresh_interval)
    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    IO.puts("Can't touch this! #{inspect(unexpected)}")
    {:noreply, state}
  end

  defp schedule_refresh(refresh_interval) do
    Process.send_after(self(), :refresh, refresh_interval)
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts("Running tasks to get sensor data...")

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end