defmodule Battle do

  # Hardcoded kill rate for performance. Might consider a function some day
  # if logic gets more complex
  # @b1 %{archetype: 1, power: 4.0,  defense: 7.0,  speed: 85.0, kill_rate: 4.0 / 7.0,   distance?: false}
  # @b2 %{archetype: 2, power: 3.0,  defense: 5.0,  speed: 86.0, kill_rate: 3.0 / 5.0,   distance?: true}
  # @b3 %{archetype: 3, power: 5.0,  defense: 9.0,  speed: 95.0, kill_rate: 5.0 / 9.0,   distance?: false}
  # @b4 %{archetype: 4, power: 5.0,  defense: 7.0,  speed: 84.0, kill_rate: 5.0 / 7.0,   distance?: true}
  # @b5 %{archetype: 5, power: 18.0, defense: 8.0,  speed: 80.0, kill_rate: 18.0 / 8.0,  distance?: false}
  # @b6 %{archetype: 6, power: 10.0, defense: 7.0,  speed: 98.0, kill_rate: 10.0 / 7.0,  distance?: true}
  # @b7 %{archetype: 7, power: 24.0, defense: 16.0, speed: 88.0, kill_rate: 24.0 / 16.0, distance?: false}
  # @b8 %{archetype: 8, power: 19.0, defense: 13.0, speed: 90.0, kill_rate: 19.0 / 13.0, distance?: true}

  # @archetypes [@b1, @b2, @b3, @b4, @b5, @b6, @b7, @b8]

  @doc """
  Solve a battle.

  From a given battle state, the function returns a battle log.
  """
  @spec solve_battle(String.t()) :: String.t()
  def solve_battle(battle_state_notation) do

    # Format battle data, filter empty units, sort by speed
    # [attacker_troup, defender_troup] = battle_state_notation
    units = battle_state_notation
    |> Notation.parse()
    |> Stream.with_index()
    |> Enum.map(fn {troup, position} ->  # Why position: attacker is first in battle state notation
      troup
      |> Stream.with_index()
      |> Enum.map(fn {v, k} ->
        Battle.Unit.new(Battle.Unit.archetype(k), v, position === 0)
      end)
      # |> Enum.sort_by(&(&1.speed), :desc)
    end)
    |> List.flatten()
    |> Enum.shuffle()  # Naturally randomize striking order on speed equality
    |> Enum.sort_by(&(&1.speed), :desc)

    # Reduce troups to battle log
    # For code conciseness:
    #   `u1` => striking unit
    #   `u2` => stricken unit
    units
    |> Enum.reduce_while(
      %{log: "#{battle_state_notation}\n", units: units},
      fn u1, acc ->
        case u1 |> choose_target(acc.units) do
          nil ->
            notation = acc.units
            |> Enum.split_with(&(&1).attacker?)
            |> Tuple.to_list()
            |> Enum.map(&Enum.map(&1, fn u -> u.count end))
            |> Notation.serialise()

            {
              :halt,
              %{
                log: (acc.log |> String.trim_trailing())
                  <> "\n"
                  <> notation,
                units: acc.units
              }
            }
          u2 ->
            if  u1.count === 0 do
              {:cont, acc}
            else
              kill_count = kill_count(u1, u2)
              damaged_u2 = %{u2 | count: u2.count - kill_count}
              {
                :cont,
                %{
                  log: acc.log
                    <> u1.label
                    <> "/"
                    <> u2.label
                    <> "/"
                    <> (kill_count |> Integer.to_string())
                    <> " ",
                  units: acc.units
                    |> Enum.map(fn unit ->
                      cond do
                        same_unit?(unit, u1) ->
                          %{unit | stroke?: true}
                        same_unit?(unit, u2) ->
                          %{unit | stricken?: true, count: damaged_u2.count}
                        true -> unit
                      end
                    end)
                }
              }
            end
        end
      end
    )
    |> Map.fetch!(:log)
  end


  # The fight between two units is divided in ticks. This allows to
  # apply a friction curve to the losses: the fewer the stricken,
  # the harder they are to kill.
  # For that friction, we use hyperbolic tangent based upon the
  # difference between the two forces.
  # Higher slope factor → less overall friction → more kills.
  # Lower slope factor → higher friction → less kills.
  #
  # Luck: Damages spread between 0.8 to 1.1 ratio.
  #
  # For conciseness:
  # u1 => Striking unit
  # u2 => Stricken unit
  @spec kill_count(Battle.Unit.t(), Battle.Unit.t()) :: integer()
  defp kill_count(u1, u2) do
    ticks = 10
    slope_factor = 4.0

    {min_spread, max_spread} = {0.8, 1.1}
    luck_ratio = min_spread + :rand.uniform() * (max_spread - min_spread)

    Enum.reduce(1..ticks, 0, fn _tick, acc_kill_count ->
      current_u2 = %{u2 | count: u2.count - acc_kill_count}

      raw_kills = u1.count * u1.power * u1.kill_rate / current_u2.defense / ticks

      friction_ratio = :math.tanh(
        current_u2.count * slope_factor / max(1, u1.count - current_u2.count)
      )

      acc_kill_count + (raw_kills * friction_ratio * luck_ratio |> min(current_u2.count))
    end)
    |> trunc()
  end

  @spec choose_target(map(), [map()]) :: map() | nil
  defp choose_target(striking_unit, stricken_troup) do
      stricken_troup
      |> Stream.reject(&(&1) |> same_side?(striking_unit))
      |> Stream.reject(&(&1.count === 0))
      |> Stream.reject(&(&1.stricken?))
      |> Enum.reject(fn unit -> !striking_unit.distance? && unit.distance? end)
      |> pick_random_or_nil()
  end
  defp pick_random_or_nil([]), do: nil
  defp pick_random_or_nil(list), do: list |> Enum.random()

  @spec same_unit?(map(), map()) :: boolean()
  defp same_unit?(a, b) do
    same_archetype?(a, b) && same_side?(a, b)
  end

  @spec same_archetype?(map(), map()) :: boolean()
  defp same_archetype?(u1, u2) do
    u1.id === u2.id
  end

  @spec same_side?(map(), map()) :: boolean()
  defp same_side?(u1, u2) do
    u1.attacker? === u2.attacker?
  end

end
