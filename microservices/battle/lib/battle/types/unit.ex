defmodule Battle.Unit do

  defstruct [
    :id,
    :power,
    :defense,
    :speed,
    :kill_rate,
    :distance?,
    :count,
    :attacker?,
    :label,
    stroke?: false,
    stricken?: false
  ]

  @type t :: %__MODULE__{
    id: non_neg_integer(),
    power: float(),
    defense: float(),
    speed: float(),
    distance?: boolean(),
    count: non_neg_integer(),
    attacker?: boolean(),
    label: String.t(),
    stroke?: boolean(),
    stricken?: boolean()
  }

  # Hardcoded kill rate for performance. Might consider a function some day
  # if logic gets more complex
  @b1 %{id: 1, power: 4.0,  defense: 7.0,  speed: 85.0, kill_rate: 4.0 / 7.0,   distance?: false}
  @b2 %{id: 2, power: 3.0,  defense: 5.0,  speed: 86.0, kill_rate: 3.0 / 5.0,   distance?: true}
  @b3 %{id: 3, power: 5.0,  defense: 9.0,  speed: 95.0, kill_rate: 5.0 / 9.0,   distance?: false}
  @b4 %{id: 4, power: 5.0,  defense: 7.0,  speed: 84.0, kill_rate: 5.0 / 7.0,   distance?: true}
  @b5 %{id: 5, power: 18.0, defense: 8.0,  speed: 80.0, kill_rate: 18.0 / 8.0,  distance?: false}
  @b6 %{id: 6, power: 10.0, defense: 7.0,  speed: 98.0, kill_rate: 10.0 / 7.0,  distance?: true}
  @b7 %{id: 7, power: 24.0, defense: 16.0, speed: 88.0, kill_rate: 24.0 / 16.0, distance?: false}
  @b8 %{id: 8, power: 19.0, defense: 13.0, speed: 90.0, kill_rate: 19.0 / 13.0, distance?: true}

  @archetypes [@b1, @b2, @b3, @b4, @b5, @b6, @b7, @b8]

  @doc """
  Construct a Unit from archetype.
  """
  @spec new(map(), non_neg_integer(), boolean(), boolean(), boolean()) :: t()
  @spec new(map(), non_neg_integer(), boolean(), boolean()) :: t()
  @spec new(map(), non_neg_integer(), boolean()) :: t()
  def new(archetype, count, attacker?, stroke? \\ false, stricken? \\ false) do
    new(
      archetype.id,
      archetype.power,
      archetype.defense,
      archetype.speed,
      archetype.distance?,
      count,
      attacker?,
      stroke?,
      stricken?
    )
  end

  @doc """
  Construct a Unit manually.
  """
  @spec new(non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer(), boolean(), non_neg_integer(), boolean(), boolean(), boolean()) :: t()
  def new(id, power, defense, speed, distance?, count, attacker?, stroke? \\ false, stricken? \\ false) do
    %__MODULE__{
      id: id,
      power: power,
      defense: defense,
      speed: speed,
      kill_rate: power / defense,
      distance?: distance?,
      count: count,
      attacker?: attacker?,
      label: (if attacker?, do: "B", else: "b") <> Integer.to_string(id),
      stroke?: stroke?,
      stricken?: stricken?
    }
  end

  @doc """
  Parse notation to data.

  ## Examples

    iex> Battle.Unit.parse_notation!("0000045")
    45

    iex> Battle.Unit.parse_notation!("-0022")
    ** (ArgumentError) Invalid notation format
  """
  @spec parse_notation!(String.t()) :: non_neg_integer()
  def parse_notation!(a) do
    cond do
      valid_notation?(a) -> a |> String.to_integer()
      true -> raise ArgumentError, message: "Invalid notation format"
    end
  end

  @doc """
  Serialise data to notation.
  """
  @spec to_notation!(t()) :: String.t()
  def to_notation!(%__MODULE__{count: c}) when c in 0..9_999_999 do
    c |> Integer.to_string() |> String.pad_leading(7, "0")
  end
  def to_notation!(_), do: raise "Invalid number of units"

  @doc """
  Validate the string representation of a unit of pieces.

  ## Examples

    iex> Battle.Unit.valid_notation?("0000995")
    true

    iex> Battle.Unit.valid_notation?("ABCD")
    false
  """
  @spec valid_notation?(String.t()) :: boolean()
  def valid_notation?(a) do
    case a do
      a when is_binary(a) -> a |> String.match?(~r/^[0-9]{7}$/)
      _ -> false
    end
  end

  @doc """
  Get all archetypes.
  """
  @spec archetypes() :: [map()]
  def archetypes(), do: @archetypes

  @doc """
  Get an archetype by key.
  """
  @spec archetype(non_neg_integer()) :: map()
  def archetype(key), do: @archetypes |> Enum.fetch!(key)
end
