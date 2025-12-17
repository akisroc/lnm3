defmodule Notation do

  @doc """
  String representation of a unit of pieces. Example:

  0000995

  This represents a unit of 995 pieces.

  Leading zeros allow for a fix string length while keeping large enough
  possibilites to never become a constraint (players will never get to
  troups of 9 millons pieces).
  """
  def is_unit_notation(a) do
    a |> String.match?(~r/^[0-9]{7}$/)
  end

  @doc """
  String representation of a troup. Example:

  0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020

  This example features a troup of 995 P1s, 20 P2s, 600 P3s, 400 P4s,
  30 P5s, no P6s, 60 P7s and 20 P8s.
  """
  def is_troup_notation(a) do
    a |> String.match?(~r/^(?:[0-9]{7}\/){7}[0-9]{7}$/)
  end

  @doc """
  String representation of the state of a battle. Example:

  0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020

  First group is the attacker troup, in the same format as TroupNotation[65].
  Second group is the defender troup.
  """
  def is_battle_state_notation(a) do
    a |> String.match?(~r/^(?:[0-9]{7}\/){7}[0-9]{7} (?:[0-9]{7}\/){7}[0-9]{7}$/)
  end

  @doc """
  @todo
  String representation of the log of a battle. Example for a three phases battle:

  @todo Complete doc example with generated log as soon as the battle solving works
  0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020\n
  P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
  P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
  P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
  0000400/0000005/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000400/00000000/0000020/0000000/0000060/0000020\n
  1

  – First line is the initial battle state.
  – Next lines are the battle phases.
      Each phase is cut in successives salvos separated by spaces.
      Each salvo is cut as follows:
        – Which piece archetype strikes (uppercase pieces (ex: P1) for attacker, lowercase (ex: p1) for defender)
        – / Which piece archetype is striken
        – / How many pieces are killed
        – / How many pieces are wounded
  – Last line is the result as a digit. 1 if attacker won. 0 if defender won. No trailing line break.

  Last two digits must be 0 for all lines before the last one, as the battle
  was not finished and the winner was not determined yet.
  """
  # def is_battle_log_notation

  @doc """
  Parse notation to data
  """
  def parse(a) do
    cond do
      is_unit_notation(a) -> a |> String.to_integer()
      is_troup_notation(a) -> a |> String.split("/") |> Enum.map(fn x -> parse(x) end)
      is_battle_state_notation(a) -> a |> String.split(" ") |> Enum.map(fn x -> parse(x) end)
      true -> raise ArgumentError, message: "Invalid notation format"
    end
  end

end
