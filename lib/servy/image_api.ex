defmodule ImageApi do
  def query(image_identifier) when is_bitstring(image_identifier) do
    case HTTPoison.get("https://api.myjson.com/bins/" <> image_identifier) do
      {:ok, response} -> parse_response(response)
      {:error, error} -> {:error, "Error connecting to api: #{inspect(error)}"}
    end
  end

  def parse_response(%HTTPoison.Response{status_code: 200} = response) do
    image_url = Poison.decode!(response.body) |> get_in(["image", "image_url"])
    {:ok, image_url}
  end

  def parse_response(%HTTPoison.Response{status_code: 500} = response) do
    reason = Poison.decode!(response.body) |> Map.get("message")
    {:error, reason}
  end
end
