defmodule Notation do

  @moduledoc """
  Handles the string notations of the game, used for recording logs and solving battles.

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

  0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020\n
  B3/b1/0000060/0000080 b6/B6/0000060/0000040 […]\n
  B3/b1/0000060/0000080 b6/B6/0000060/0000040 […]\n
  B3/b1/0000060/0000080 b6/B6/0000060/0000040 […]\n
  0000400/0000005/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000400/00000000/0000020/0000000/0000060/0000020\n
  1

  Lines end in line breaks `\n`.

  - First line is the initial battle state.
  - Next lines are the battle phases.
      Each phase is cut in successives salvos separated by spaces ` `.
      Each salvo is cut as follows:
        - Which piece archetype strikes (uppercase pieces (ex: B1) for attacker,
          lowercase (ex: b1) for defender)
        - Delimiter `/` then which piece archetype is stricken
        - Delimiter `/` then how many pieces are killed
        - Delimiter `/` then how many pieces are wounded
  - Last line is the result as a digit. 1 if attacker won. 0 if defender won.
    No trailing line break.

  ----

  /?\
  Why the `B` letter for a piece archetype? (:
  Ex: B1, B2, B3, etc.
  Years ago, when LNM was a popular PHP game in France, what I call now "pieces"
  by convention were soldiers trained in barracks. The word used in french for
  these barracks was "Bâtiment", so players were used to design these soldiers
  archetypes by B1, B3, B8, etc.
  "Une armée de B1 et B3" was a thing!
  I kept this naming tradition in the codebase by respect to the old LNM.
  """

  @doc """
  Validate the string representation of a unit of pieces.

  ## Examples

    iex> Notation.unit_notation?("0000995")
    true

    iex> Notation.unit_notation?("ABCD")
    false
  """
  @spec unit_notation?(String.t()) :: boolean()
  def unit_notation?(a) do
    case a do
      a when is_binary(a) -> a |> String.match?(~r/^[0-9]{7}$/)
      _ -> false
    end
  end

  @doc """
  Validate the string representation of a troup.

  ## Examples

    iex> Notation.troup_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    true

    iex> Notation.troup_notation?("9999999-1111111")
    false
  """
  @spec troup_notation?(String.t()) :: boolean()
  def troup_notation?(a) do
    case a do
      a when is_binary(a) -> a |> String.match?(~r/^(?:[0-9]{7}\/){7}[0-9]{7}$/)
      _ -> false
    end
  end

  @doc """
  Validate the string representation of the state of a battle.

  ## Examples

    iex> Notation.battle_state_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    true

    iex> Notation.battle_state_notation?("Hello")
    false
  """
  @spec battle_state_notation?(String.t()) :: boolean()
  def battle_state_notation?(a) do
    case a do
      a when is_binary(a) -> a |> String.match?(~r/^(?:[0-9]{7}\/){7}[0-9]{7} (?:[0-9]{7}\/){7}[0-9]{7}$/)
      _ -> false
    end
  end

  @doc """
  Validate the integer representation of a unit of pieces.
  Must be an integer between 0 and 9999999.

  ## Examples

    iex> Notation.unit_count?(99234)
    true

    iex> Notation.unit_count?(-45)
    false
  """
  @spec unit_count?(non_neg_integer()) :: boolean()
  def unit_count?(i), do: is_integer(i) && i >= 0 && i <= 9999999

  @doc """
  Validate the list representation of a troup.
  Must be a list of 8 integers between 0 and 9999999

  ## Examples

    iex> Notation.troup_list?([45, 992, 22, 10, 0, 0, 1520, 500])
    true

    iex> Notation.troup_list?([45, 22, 30])
    false
  """
  @spec troup_list?([non_neg_integer()]) :: boolean()
  def troup_list?(l), do: is_list(l) && length(l) === 8 && l |> Enum.all?(&unit_count?/1)

  @doc """
  Validate the list representation of a battle state.
  Must be a list of 2 lists of 8 integers between 0 and 999999999

  ## Examples

    iex> Notation.battle_state_list?([[45, 992, 22, 10, 0, 0, 1520, 500], [45, 992, 22, 10, 0, 0, 1520, 500]])
    true

    iex> Notation.battle_state_list?([[75, 20], [1], [0, 0, 60220]])
    false
  """
  @spec battle_state_list?([[non_neg_integer()]]) :: boolean()
  def battle_state_list?(l), do: is_list(l) && length(l) === 2 && l |> Enum.all?(&troup_list?/1)

  @doc """
  Parse notation to data.

  ## Examples

    iex> Notation.parse("0000045")
    45

    iex> Notation.parse("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    [995, 20, 600, 400, 30, 0, 60, 20]

    iex> Notation.parse("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    [[995, 20, 600, 400, 30, 0, 60, 20], [995, 20, 600, 400, 30, 0, 60, 20]]
  """
  @spec parse(String.t()) :: non_neg_integer() | [non_neg_integer()] | [[non_neg_integer()]]
  def parse(a) do
    cond do
      unit_notation?(a) -> a |> String.to_integer()
      troup_notation?(a) -> a |> String.split("/") |> Enum.map(&parse/1)
      battle_state_notation?(a) -> a |> String.split(" ") |> Enum.map(&parse/1)
      true -> raise ArgumentError, message: "Invalid notation format"
    end
  end

  @doc """
  Serialise data to notation

  ## Examples

    iex> Notation.serialise(45)
    "0000045"
  """
  @spec serialise(non_neg_integer() | [non_neg_integer()] | [[non_neg_integer()]]) :: String.t()
  def serialise(x) do
    cond do
      unit_count?(x) -> x |> Integer.to_string() |> String.pad_leading(7, "0")
      troup_list?(x) -> x |> Enum.map(&serialise/1) |> Enum.join("/")
      battle_state_list?(x) -> x |> Enum.map(&serialise/1) |> Enum.join(" ")
      true -> raise ArgumentError, message: "Invalid notation data"
    end
  end

end
