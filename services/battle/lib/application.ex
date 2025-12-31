defmodule Battle.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {GRPC.Server.Supervisor, endpoint: {Battle.Server, 50051}}
    ]

    opts = [strategy: :one_for_one, name: Battle.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
