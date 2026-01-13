defmodule Platform.Sovereignty.War.Types.BattleLogEntry do
  alias Platform.Sovereignty.War.Types.Unit

  defstruct [
    :attacking_unit,
    :defending_unit,
    :kill_steps
  ]

  @type t :: %__MODULE__{
    attacking_unit: Unit.t(),
    defending_unit: Unit.t(),
    kill_steps: [non_neg_integer()]
  }

  @spec to_raw(__MODULE__.t()) :: map()
  def to_raw(__MODULE__{} = log_entry) do
    %{
      attacking_unit:
        log_entry.attacking_unit.archetype.label
        |> Atom.to_string()
        |> String.upcase(),
      defending_unit:
        log_entry.attacking_unit.archetype.label
        |> Atom.to_string()
        |> String.downcase(),
      kill_steps:
        log_entry.kill_steps
    }
  end
end
