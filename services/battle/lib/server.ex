defmodule Battle.Server do
  use GRPC.Server, service: Battle.BattleService.Service

  def solve_battle(request, _stream) do
    Battle.BattleResponse.new(
      result: Battle.solve_battle(request.notation)
    )
  end
end
