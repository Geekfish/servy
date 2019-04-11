require Logger

defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView

  # @templates_path Path.expand("templates", File.cwd!())

  # defp render(conv, template, bindings \\ []) do
  #   content =
  #     @templates_path
  #     |> Path.join(template)
  #     |> EEx.eval_file(bindings)

  #   %{conv | status: 200, resp_body: content}
  # end

  defp render(conv, content) do
    %{conv | status: 200, resp_body: content}
  end

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, BearView.index(bears))
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render(conv, BearView.show(bear))
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{
      conv
      | status: 201,
        resp_body: "Created a #{type} bear named #{name}!"
    }
  end

  def delete(conv, %{"id" => id}) do
    Logger.error("Someone tried to remove a bear :(")
    %{conv | status: 403, resp_body: "Bear ##{id} cannot be removed!"}
  end
end
