defmodule Battle.Troup do

  defstruct [
    :units,
    :attacker?
  ]

  @type t :: %__MODULE__{
    units: [Battle.Unit.t()],
    attacker?: boolean()
  }

  @doc """
  Construct a Troup from notation, or from a list of Units.
  """
  @spec new(String.t(), boolean()) :: t()
  def new(notation, attacker?) when is_binary(notation) do
    new(
      notation
      |> parse_notation!()
      |> Stream.with_index()
      |> Enum.map(fn {v, k} ->
        Battle.Unit.new(Battle.Unit.archetype(k), v, attacker?)
      end),
      attacker?
    )
  end
  @spec new([Battle.Unit.t()], boolean()) :: t()
  def new(units, attacker?) do
    %__MODULE__{
      units: units,
      attacker?: attacker?
    }
  end

  @doc """
  Total power of all units in given troup.
  """
  @spec total_power(t()) :: non_neg_integer()
  def total_power(troup) do
    troup.units |> Stream.map(&(&1.power * &1.count)) |> Enum.sum()
  end

  @doc """
  Total defense of all units in given troup.
  """
  @spec total_defense(t()) :: non_neg_integer()
  def total_defense(troup) do
    troup.units |> Stream.map(&(&1.defense * &1.count)) |> Enum.sum()
  end

  @doc """
  Parse notation to data

  ## Examples

    iex> Battle.Troup.parse_notation!("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    [995, 20, 600, 400, 30, 0, 60, 20]

    iex> Battle.Troup.parse_notation!("/0000400/0000030/0000000/0000060/0000020")
    ** (ArgumentError) Invalid notation format
  """
  @spec parse_notation!(String.t()) :: [non_neg_integer()]
  def parse_notation!(a) do
    cond do
      valid_notation?(a) ->
        a |> String.split("/") |> Enum.map(&Battle.Unit.parse_notation!/1)
      true -> raise ArgumentError, message: "Invalid notation format"
    end
  end

  @doc """
  Serialise troup to its string notation representation.
  """
  @spec to_notation!(t()) :: String.t()
  def to_notation!(troup) do
    notation = troup.units
    |> Stream.map(&Battle.Unit.to_notation!/1)
    |> Enum.join("/")

    if !valid_notation?(notation) do
      raise "Could not generate valid notation from troup"
    end

    notation
  end

  @doc """
  Validate the string representation of a troup.

  ## Examples

    iex> Battle.Troup.valid_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    true

    iex> Battle.Troup.valid_notation?("9999999-1111111")
    false
  """
  @spec valid_notation?(String.t()) :: boolean()
  def valid_notation?(a) do
    case a do
      a when is_binary(a) -> a |> String.match?(~r/^(?:[0-9]{7}\/){7}[0-9]{7}$/)
      _ -> false
    end
  end

end
