defmodule Platform.Game.UnitArchetype do
  @moduledoc """
  Defines the static attributes for unit archetypes.

  ### Kill rate

  **Kill rate** of an archetype is defined as the **ratio of power to
  defense**. This quotient is hardcoded for performance purposes.

  **Example (B1):**

  `4.0 / 7.0 = 0.5714285714285714`, so let’s make it `0.57`.

  ### Fame cost

  **Fame cost** is derived from old LNM data. Soldiers were recruited in
  barracks. Each barrack of a certain archetype occupied a certain number
  of hectares, and allowed to recruit a certain number of soldiers. In this
  new version, barracks are removed, so soldiers are directly recruited. But
  the hectares were a key resource of LNM’s strategical aspects, so the
  mechanism has been translated into the newly introduced **fame** resource.

  **Example (B1):**

  B1 barracks required 100 hectares to build and allowed to recruit 35 soldiers.
  So each B1 soldier required in fact `100 / 35 = 2.857142857142857` hectares to
  recruit. So let’s round it to `2.86` for its individual fame cost.
  """

  defstruct [
    :label,
    :power,
    :defense,
    :speed,
    :kill_rate,
    :distance?,
    :fame_cost
  ]

  @type t :: %__MODULE__{
    label: atom(),
    power: float(),
    defense: float(),
    speed: float(),
    kill_rate: float(),
    distance?: boolean(),
    fame_cost: float()
  }

  def get(1), do: b1()
  def get(:b1), do: b1()

  def get(2), do: b2()
  def get(:b2), do: b2()

  def get(3), do: b3()
  def get(:b3), do: b3()

  def get(4), do: b4()
  def get(:b4), do: b4()

  def get(5), do: b5()
  def get(:b5), do: b5()

  def get(6), do: b6()
  def get(:b6), do: b6()

  def get(7), do: b7()
  def get(:b7), do: b7()

  def get(8), do: b8()
  def get(:b8), do: b8()

  def all do
    [get(1), get(2), get(3), get(4), get(5), get(6), get(7), get(8)]
  end

  defp b1 do
    %__MODULE__{
      label: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      distance?: false,
      fame_cost: 2.86
    }
  end

  defp b1 do
    %__MODULE__{
      label: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      distance?: false,
      fame_cost: 2.86
    }
  end

  defp b1 do
    %__MODULE__{
      label: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      distance?: false,
      fame_cost: 2.86
    }
  end

  defp b1 do
    %__MODULE__{
      label: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      distance?: false,
      fame_cost: 2.86
    }
  end

  defp b1 do
    %__MODULE__{
      label: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      distance?: false,
      fame_cost: 2.86
    }
  end

  defp b1 do
    %__MODULE__{
      label: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      distance?: false,
      fame_cost: 2.86
    }
  end

  defp b1 do
    %__MODULE__{
      label: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      distance?: false,
      fame_cost: 2.86
    }
  end

  defp b1 do
    %__MODULE__{
      label: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      distance?: false,
      fame_cost: 2.86
    }
  end
end
