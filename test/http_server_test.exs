defmodule HttpServerTest do
  use ExUnit.Case, async: true

  test "Server returns bears" do
    server_pid = spawn(Servy.HttpServer, :start, [4001, self()])

    receive do
      {^server_pid, :ready} -> nil
    end

    1..5
    |> Enum.map(fn _ -> Task.async(HTTPoison, :get, ["http://localhost:4001/wildthings"]) end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(fn {:ok, response} ->
      assert response.status_code == 200
      assert response.body == "Bears, Lions, Tigers"
    end)
  end

  test "Server returns 200" do
    server_pid = spawn(Servy.HttpServer, :start, [4002, self()])

    receive do
      {^server_pid, :ready} ->
        nil
    end

    [
      "wildthings",
      "about",
      "pages/faq",
      "bears/new",
      "bears/1",
      "bears",
      "api/bears"
    ]
    |> Enum.map(fn endpoint ->
      Task.async(HTTPoison, :get, ["http://localhost:4002/" <> endpoint])
    end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(fn {:ok, response} ->
      assert response.status_code == 200
    end)
  end
end
