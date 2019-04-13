defmodule Servy.HttpClient do
  @bear_host 'localhost'
  @bear_port 4000

  def send_request(request) do
    {:ok, sock} = :gen_tcp.connect(@bear_host, @bear_port, [:binary, packet: 0, active: false])
    :ok = :gen_tcp.send(sock, request)
    {:ok, response} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)
    response
  end

  def request_bears() do
    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = send_request(request)
    IO.puts("⬇ Received response:\n")
    IO.puts(response)
  end
end
