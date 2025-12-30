defmodule Battle.BattleState do
  defstruct [
    :attacker_troup,
    :defender_troup
  ]

  @type t :: %__MODULE__{
    attacker_troup: Battle.Troup.t(),
    defender_troup: Battle.Troup.t()
  }

  @doc """
  Construct from string notation.
  """
  @spec new(String.t()) :: t()
  def new(notation) do
    [attacker_troup, defender_troup] = notation
    |> String.split(" ")
    |> Stream.with_index()
    |> Enum.map(fn {troup_notation, position} ->
      # Why position: attacker is first in battle state notation
      Battle.Troup.new(troup_notation, position === 0)
    end)

    new(attacker_troup, defender_troup)
  end

  @doc """
  Construct from attacker and defender Troups.
  """
  @spec new(Battle.Troup.t(), Battle.Troup.t()) :: t()
  def new(attacker_troup, defender_troup) do
    %__MODULE__{
      attacker_troup: attacker_troup,
      defender_troup: defender_troup
    }
  end

  @doc """
  Get all Troups from a BattleState.
  """
  @spec troups(t()) :: [Battle.Troup]
  def troups(battle_state) do
    [battle_state.attacker_troup, battle_state.defender_troup]
  end

  @doc """
  Get all flattened Units from a BattleState.
  """
  @spec units(t()) :: [Battle.Unit]
  def units(battle_state) do
    battle_state
    |> troups()
    |> Enum.map(&(&1.units))
    |> List.flatten()
  end

  @doc """
  Parse notation to data.

  ## Examples

    iex> Battle.BattleState.parse_notation!("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    [[995, 20, 600, 400, 30, 0, 60, 20], [995, 20, 600, 400, 30, 0, 60, 20]]

    iex> Battle.BattleState.parse_notation!("I/am/not/a/valid/notation")
    ** (ArgumentError) Invalid notation format
  """
  @spec parse_notation!(String.t()) :: [[non_neg_integer()]]
  def parse_notation!(a) do
    cond do
      valid_notation?(a) ->
        a |> String.split(" ") |> Enum.map(&Battle.Troup.parse_notation!/1)
      true -> raise ArgumentError, message: "Invalid notation format"
    end
  end

  @doc """
  Serialise BattleState to notation.
  """
  @spec to_notation!(t()) :: String.t()
  def to_notation!(battle_state) do
    notation = [battle_state.attacker_troup, battle_state.defender_troup]
    |> Stream.map(&Battle.Troup.to_notation!/1)
    |> Enum.join(" ")

    if !valid_notation?(notation) do
      raise "Could not generate valid notation from battle state"
    end

    notation
  end

  @doc """
  Validate the string representation of the state of a battle.

  ## Examples

    iex> Battle.BattleState.valid_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    true

    iex> Battle.BattleState.valid_notation?("Hello")
    false
  """
  @spec valid_notation?(String.t()) :: boolean()
  def valid_notation?(a) do
    case a do
      a when is_binary(a) -> a |> String.match?(~r/^(?:[0-9]{7}\/){7}[0-9]{7} (?:[0-9]{7}\/){7}[0-9]{7}$/)
      _ -> false
    end
  end
end
