defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [file_response: 2, markdown_to_html: 1]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, put_content_length: 1]

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Api.BearController, as: ApiBearController
  alias Servy.VideoCam
  alias Servy.BearView

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

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = Servy.FourOhFourCounter.get_counts()
    %{conv | status: 200, resp_body: "404s so far: #{inspect(counts)}"}
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    task = Task.async(Servy.Tracker, :get_location, ["bigfoot"])

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(VideoCam, :get_snapshot, [&1]))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task, :timer.seconds(2))

    %{conv | status: 200, resp_body: BearView.sensors(snapshots, where_is_bigfoot)}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()
    %{conv | status: 200, resp_body: "Awake!"}
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

  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    @pages_path
    |> Path.join("faq.md")
    |> File.read()
    |> file_response(conv)
    |> markdown_to_html
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page_name} = conv) do
    @pages_path
    |> Path.join("#{page_name}.html")
    |> File.read()
    |> file_response(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
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
