defmodule Servy.FileHandler do
  alias Servy.Conv

  def file_response({:ok, contents}, %Conv{} = conv) do
    %{conv | status: 200, resp_body: contents}
  end

  def file_response({:error, :enoent}, %Conv{} = conv) do
    %{conv | status: 404, resp_body: "File not found"}
  end

  def file_response({:error, reason}, %Conv{} = conv) do
    %{conv | status: 500, resp_body: "Could not retrieve about page: #{reason}"}
  end
end
