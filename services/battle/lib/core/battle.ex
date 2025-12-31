defmodule Battle do

  @moduledoc """
  Handle battles.

  The game uses string notations for recording logs and solving battles.

  --------

  The notation for a **unit** of pieces looks like this:

  "0000995"

  This represents a unit of 995 pieces.

  Leading zeros allow for a fix string length while keeping large enough
  possibilites to never become a constraint (players will never get to
  troups of 9 millons pieces).

  --------

  The notation for a **troup** looks like this:

  "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020"

  This example features a troup of 995 B1s, 20 B2s, 600 B3s, 400 B4s,
  30 B5s, no B6s, 60 B7s and 20 B8s, all delimited by a slash character `/`.

  --------

  The notation for a **battle state** looks like this:

  "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020"

  This represents the state of the two fighting troup at a given time.
  First group is the attacker troup, in the same format as a troup notation.
  Second group, after a space delimiter ` `, is the defender troup.

  --------

  @todo Complete this section example with generated log as soon as the battle solving works

  The notation for a **battle log** looks like this

  ```
  0000995/0000400/0000600/0000800/0001200/0000660/0000450/0000020 0001500/0000135/0001000/0000100/0000200/0000000/0000600/0000100\n
  B6/b3/923 B3/b7/89 b3/B1/406 B8/b5/72 b8/B2/400 B7/b1/1500 b7/B3/600 b2/B6/37 B2/b4/59\n
  0000623/0000000/0000020/0000450/0000000/0000589/0000800/0001200 0000000/0000077/0000100/0000511/0000135/0000000/0000041/0000128\n
  1
  ```

  Lines end in line breaks `\n`.

  - First line is the initial battle state.
  - Next line is for the successive salvos. Each salvo is cut as follows:
      - Which piece archetype strikes (uppercase pieces (ex: B1) for attacker,
        lowercase (ex: b4) for defender)
      - Delimiter `/` then which piece archetype is stricken (same case
        convention for attacker and defender)
      - Delimiter `/` then how many pieces are killed
  – Next line is the final battle state.
  - Last line is the result as a digit. 1 if attacker won. 0 if defender won.
    No trailing line break.

  ----

  /?\
  Why the `B` letter for a piece archetype? (:
  Ex: B1, B2, B3, etc.
  Years ago, when LNM was a popular PHP game in France, what I call now "pieces"
  by convention were soldiers trained in barracks. The word used in french for
  these barracks is "Bâtiment", so players were used to design these soldiers
  archetypes by B1, B3, B8, etc.
  "Une armée de B1 et B3" was a thing!
  I kept this naming tradition in the codebase by respect to the old LNM,
  and because it’s convinient.
  """

  @doc """
  Solve a battle.

  From a given battle state, the function returns a battle log.
  """
  @spec solve_battle(String.t()) :: String.t()
  def solve_battle(battle_state_notation) do
    units = Battle.BattleState.new(battle_state_notation)
    |> Battle.BattleState.units()
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
            {a_units, b_units} = acc.units |> Enum.split_with(&(&1).attacker?)
            a_troup = Battle.Troup.new(a_units, true)
            b_troup = Battle.Troup.new(b_units, false)
            notation = Battle.BattleState.new(a_troup, b_troup)
            |> Battle.BattleState.to_notation!()

            {
              :halt,
              %{
                log: [
                  acc.log |> IO.iodata_to_binary() |> String.trim_trailing(), "\n",
                  notation, "\n",
                  (if attacker_wins?(a_troup, b_troup), do: "1", else: "0")
                ],
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
                  log: [
                    acc.log, u1.label, "/", u2.label, "/", (kill_count |> Integer.to_string()), " "
                  ],
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
    |> Map.fetch!(:log) |> IO.iodata_to_binary()
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

  @spec attacker_wins?(Battle.Troup.t(), Battle.Troup.t()) :: boolean()
  defp attacker_wins?(t1, t2) do
    (Battle.Troup.total_power(t1) / Battle.Troup.total_defense(t2)) >= 1.6
  end

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
