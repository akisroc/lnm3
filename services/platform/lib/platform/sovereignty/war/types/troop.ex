defmodule Platform.Sovereignty.War.Types.Troop do
  alias Platform.Sovereignty.War.Types.Unit

  defstruct [
    :attacker?,
    :units
  ]

  @type t :: %__MODULE__{
    attacker?: boolean(),
    units: [Unit.t()]
  }

  @doc """
  `units` parameter must be a list a 8 positive integers.
  See: Platform.Sovereignty.Ecto.Types.Troop
  """
  @spec from_raw_troop([non_neg_integer()], boolean()) :: __MODULE__.t()
  def from_raw_troop(units, attacker?) do
    if Enum.all?(units, &is_integer/1) and length(units) === 8 do
      {
        :ok,
        %__MODULE__{
          attacker?: attacker?,
          units: units
          |> Stream.with_index(1)
          |> Enum.map(fn {unit_count, identifier} ->
            %Unit{
              archetype: UnitArchetype.get!(identifier),
              count: unit_count,
              attacker?: attacker?,
              stroke?: false,
              stricken?: false
            }
          end)
        }
      }
    else
      {:error, :invalid_raw_troop_format}
    end
  end

  @spec(__MODULE__.t()) :: [non_neg_integer()]
  def to_raw_troop(%__MODULE__{units: units}) do
    units |> Enum.map(fn %{count: count} -> count end)
  end

  @spec military_strength(__MODULE.t()) :: non_neg_integer()
  def military_strength(troop) do
    troop |> Enum.reduce(0.0, fn unit, acc ->
      acc + Unit.military_strength(unit)
    end)
  end

  @spec count(__MODULE__.t()) :: non_neg_integer()
  def count(troop) do
    troop |> Enum.reduce(0, fn unit, acc -> acc + unit.count end)
  end
end
