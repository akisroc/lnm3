defmodule Platform.Sovereignty.War.Types.UnitArchetype do

  @moduledoc """
  Defines the static attributes for unit archetypes.

  Most of the values are derived directly or indirectly from legacy
  LNM codebase.

  > **Note**
  >
  > Why the `B` letter for a piece archetype? (:
  >
  > Ex: B1, B2, B3, etc.
  >
  > Years ago, when LNM was a popular PHP game in France, what I call now "pieces"
  > by convention were soldiers trained in barracks. The word used in french for
  > these barracks was "Bâtiment", so players were used to design these soldiers
  > archetypes by B1, B3, B8, etc.
  >
  > "Une armée de B1 et B3" was a thing! I kept this naming tradition in the
  > codebase by respect to the old LNM.

  ### Kill rate

  **Kill rate** of an archetype is defined as the **ratio of power to
  defense**. This quotient is hardcoded for performance purposes.

  **Example (B1):**

  `4.0 / 7.0 = 0.5714285714285714`, so let’s make it `0.57`.

  ### Fame drain rate

  **Fame drain rate** is based upon old LNM data, repurposing the former
  plunder rates. This value is a foundation for fame extraction mathematics
  when a kingdom defeats another one in battle.

  **Example (B1):**

  B1 archetype was renowned for being a pretty weak unit in fight but
  with a very high plunder rate. Its value was `6.0`, so let’s keep it.

  ### Fame cost

  **Fame cost** is also derived from old LNM data. Soldiers were recruited in
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

  @fields [
    :key,
    :power,
    :defense,
    :speed,
    :kill_rate,
    :fame_drain_rate,
    :distance?,
    :fame_cost
  ]

  @enforce_keys @fields
  defstruct @fields

  @type t :: %__MODULE__{
    key: atom(),
    power: float(),
    defense: float(),
    speed: float(),
    kill_rate: float(),
    fame_drain_rate: float(),
    distance?: boolean(),
    fame_cost: float()
  }

  @spec get(non_neg_integer() | atom()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def get(1), do: {:ok, b1()}
  def get(:b1), do: {:ok, b1()}
  def get(2), do: {:ok, b2()}
  def get(:b2), do: {:ok, b2()}
  def get(3), do: {:ok, b3()}
  def get(:b3), do: {:ok, b3()}
  def get(4), do: {:ok, b4()}
  def get(:b4), do: {:ok, b4()}
  def get(5), do: {:ok, b5()}
  def get(:b5), do: {:ok, b5()}
  def get(6), do: {:ok, b6()}
  def get(:b6), do: {:ok, b6()}
  def get(7), do: {:ok, b7()}
  def get(:b7), do: {:ok, b7()}
  def get(8), do: {:ok, b8()}
  def get(:b8), do: {:ok, b8()}
  def get(wrong_id) do
    {:error, "Wrong identifier `#{wrong_id}` for unit archetype"}
  end

  @spec get!(non_neg_integer() | atom()) :: __MODULE__.t()
  def get!(1), do: b1()
  def get!(:b1), do: b1()
  def get!(2), do: b2()
  def get!(:b2), do: b2()
  def get!(3), do: b3()
  def get!(:b3), do: b3()
  def get!(4), do: b4()
  def get!(:b4), do: b4()
  def get!(5), do: b5()
  def get!(:b5), do: b5()
  def get!(6), do: b6()
  def get!(:b6), do: b6()
  def get!(7), do: b7()
  def get!(:b7), do: b7()
  def get!(8), do: b8()
  def get!(:b8), do: b8()
  def get!(wrong_id) do
    raise ArgumentError, message: "Wrong identifier `#{wrong_id}` for unit archetype"
  end

  @spec all :: [__MODULE__.t()]
  def all do
    [get!(1), get!(2), get!(3), get!(4), get!(5), get!(6), get!(7), get!(8)]
  end

  defp b1 do
    %__MODULE__{
      key: :b1,
      power: 4.0,
      defense: 7.0,
      speed: 85.0,
      kill_rate: 0.57,
      fame_drain_rate: 6.0,
      distance?: false,
      fame_cost: 2.86
    }
  end

  defp b2 do
    %__MODULE__{
      key: :b2,
      power: 3.0,
      defense: 5.0,
      speed: 86.0,
      kill_rate: 0.6,
      fame_drain_rate: 2.0,
      distance?: true,
      fame_cost: 3.14
    }
  end

  defp b3 do
    %__MODULE__{
      key: :b3,
      power: 5.0,
      defense: 9.0,
      speed: 95.0,
      kill_rate: 0.55,
      fame_drain_rate: 3.0,
      distance?: false,
      fame_cost: 4.5
    }
  end

  defp b4 do
    %__MODULE__{
      key: :b4,
      power: 5.0,
      defense: 7.0,
      speed: 84.0,
      kill_rate: 0.71,
      fame_drain_rate: 2.0,
      distance?: true,
      fame_cost: 5.33
    }
  end

  defp b5 do
    %__MODULE__{
      key: :b5,
      power: 18.0,
      defense: 8.0,
      speed: 80.0,
      kill_rate: 2.25,
      fame_drain_rate: 3.0,
      distance?: false,
      fame_cost: 7.2
    }
  end

  defp b6 do
    %__MODULE__{
      key: :b6,
      power: 10.0,
      defense: 7.0,
      speed: 98.0,
      kill_rate: 1.43,
      fame_drain_rate: 3.0,
      distance?: true,
      fame_cost: 8.0
    }
  end

  defp b7 do
    %__MODULE__{
      key: :b7,
      power: 24.0,
      defense: 16.0,
      speed: 88.0,
      kill_rate: 1.5,
      fame_drain_rate: 4.0,
      distance?: false,
      fame_cost: 12.0
    }
  end

  defp b8 do
    %__MODULE__{
      key: :b8,
      power: 19.0,
      defense: 13.0,
      speed: 90.0,
      kill_rate: 1.46,
      fame_drain_rate: 3.0,
      distance?: true,
      fame_cost: 13.25
    }
  end
end
