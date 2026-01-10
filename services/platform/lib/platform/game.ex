defmodule Platform.Game do
  alias Platform.Game.Kingdom

  @spec attack(Kingdom.t(), Kingdom.t()) :: {:ok, Battle.t()} | {:error, any()}
  def attack(%Kingdom{} = attacker, %Kingdom{} = defender) do
    units = [
      attacker.attack_troup |> Enum.map(fn x -> {:attacker, x} end),
      defender.defense_troup |> Enum.map(fn x -> {:defender, x} end)
    ]
    |> List.flatten()
  end
end
