defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [file_response: 2]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, put_content_length: 1]

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Api.BearController, as: ApiBearController

  @pages_path Path.expand("pages", File.cwd!())

  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> file_response(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page_name} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("#{page_name}.html")
    |> File.read()
    |> file_response(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("form.html")
    |> File.read()
    |> file_response(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> bear_id} = conv) do
    params = Map.put(conv.params, "id", bear_id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> bear_id} = conv) do
    params = Map.put(conv.params, "id", bear_id)
    BearController.delete(conv, params)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    ApiBearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    ApiBearController.create(conv, conv.params)
  end

  def route(%Conv{} = conv) do
    %{conv | status: 404, resp_body: "Path #{conv.path} not found"}
  end

  def format_response_headers(conv) do
    conv.resp_headers
    |> Enum.map(fn {k, v} -> "#{k}: #{v}\r" end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end
end
