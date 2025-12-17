import gleam/regexp
import gleam/string
import gleam/int
import gleam/list
import gleam/result


/// String representation of a unit of pieces. Example:
///
/// 0000995
///
/// This represents a unit of 995 pieces.
///
/// Leading zeros allow for a fix string length while keeping large enough
/// possibilites to never become a constraint (players will never get to
/// troups of 9 millons pieces).
///
pub fn is_unit_notation(a: String) -> Bool {
  let assert Ok(re) = regexp.from_string("^[0-9]{7}$")
  regexp.check(with: re, content: a)
}

/// String representation of a troup. Example:
///
/// 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020
///
/// This example features a troup of 995 P1s, 20 P2s, 600 P3s, 400 P4s,
/// 30 P5s, no P6s, 60 P7s and 20 P8s.
///
pub fn is_troup_notation(a: String) -> Bool {
  let assert Ok(re) = regexp.from_string("^(?:[0-9]{7}/){7}[0-9]{7}$")
  regexp.check(with: re, content: a)
}

/// String representation of the state of a battle. Example:
///
/// 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020
///
/// First group is the attacker troup, in the same format as TroupNotation[65].
/// Second group is the defender troup.
///
pub fn is_battle_state_notation(a: String) -> Bool {
  let assert Ok(re) = regexp.from_string("^(?:[0-9]{7}/){7}[0-9]{7} (?:[0-9]{7}/){7}[0-9]{7}$")
  regexp.check(with: re, content: a)
}

/// @todo
/// String representation of the log of a battle. Example for a three phases battle:
///
/// @todo Complete doc example with generated log as soon as the battle solving works
/// 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020\n
/// P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
/// P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
/// P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
/// 0000400/0000005/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000400/00000000/0000020/0000000/0000060/0000020\n
/// 1
///
/// – First line is the initial battle state.
/// – Next lines are the battle phases.
///     Each phase is cut in successives salvos separated by spaces.
///     Each salvo is cut as follows:
///       – Which piece archetype strikes (uppercase pieces (ex: P1) for attacker, lowercase (ex: p1) for defender)
///       – / Which piece archetype is striken
///       – / How many pieces are killed
///       – / How many pieces are wounded
/// – Last line is the result as a digit. 1 if attacker won. 0 if defender won. No trailing line break.
///
/// Last two digits must be 0 for all lines before the last one, as the battle
/// was not finished and the winner was not determined yet.
//pub fn is_battle_log_notation(a: String) -> Bool {
//
//}

pub fn parse_unit(a: String) -> Result(Int, String) {
  case is_unit_notation(a) {
    True -> {
      a
      |> int.parse
      |> result.replace_error("Integer parsing error")
    }
    False -> Error("Invalid unit notation format")
  }
}

pub fn parse_troup(a: String) -> Result(List(Int), String) {
  case is_troup_notation(a) {
    True -> {
      a
      |> string.split("/")
      |> list.map(parse_unit)
      |> result.all
    }
    False -> Error("Invalid troup notation format")
  }
}

pub fn parse_battle_state(a: String) -> Result(List(List(Int)), String) {
  case is_battle_state_notation(a) {
    True -> {
      a
      |> string.split(" ")
      |> list.map(parse_troup)
      |> result.all
    }
    False -> Error("Invalid battle state notation format")
  }
}
