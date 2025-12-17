import gleeunit
import liblnm3/notation

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn is_unit_notation_test() {
  assert True == notation.is_unit_notation("0000000")
  assert True == notation.is_unit_notation("0000950")
  assert True == notation.is_unit_notation("0022345")
  assert True == notation.is_unit_notation("1234590")
  assert True == notation.is_unit_notation("2000000")

  assert False == notation.is_unit_notation("00002345")
  assert False == notation.is_unit_notation("0023445567")
  assert False == notation.is_unit_notation("234")
  assert False == notation.is_unit_notation("000")
  assert False == notation.is_unit_notation("0")

  assert False == notation.is_unit_notation("000000A")
  assert False == notation.is_unit_notation("ABCdef1")

  assert False == notation.is_unit_notation("")
  assert False == notation.is_unit_notation(" ")
}

pub fn is_troup_notation_test() {
  assert True
    == notation.is_troup_notation(
      "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020",
    )
  assert True
    == notation.is_troup_notation(
      "0000000/0000000/0000000/0000000/0000000/0000000/0000000/0000000",
    )
  assert True
    == notation.is_troup_notation(
      "9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999",
    )

  // No zero padding
  assert False == notation.is_troup_notation("995/20/600/400/30/0/60/20")
  // Too many units
  assert False
    == notation.is_troup_notation(
      "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020/0000450",
    )
  // Not enough units
  assert False
    == notation.is_troup_notation(
      "0000995/0000020/0000600/0000400/0000030/0000000/0000060",
    )
  // Trailing separator
  assert False
    == notation.is_troup_notation(
      "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020/",
    )
  // Leading separator
  assert False
    == notation.is_troup_notation(
      "/0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020",
    )
  // Wrong separator
  assert False
    == notation.is_troup_notation(
      "0000995 0000020 0000600 0000400 0000030 0000000 0000060 0000020",
    )
  // No separator
  assert False
    == notation.is_troup_notation(
      "00009950000020000060000004000000030000000000000600000020",
    )
  // Letters
  assert False
    == notation.is_troup_notation(
      "0000995/ABCDEFG/0000600/0000400/0000030/0000000/0000060/0000020",
    )
}

pub fn is_battle_state_notation_test() {
  assert True
    == notation.is_battle_state_notation(
      "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020",
    )

  // Too many troups
  assert False
    == notation.is_battle_state_notation(
      "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020",
    )
  // Not enough troups
  assert False
    == notation.is_battle_state_notation(
      "9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999",
    )
}

pub fn parse_unit_test() {
  // @todo
  echo notation.parse_unit("0000995")
  echo notation.parse_troup(
    "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020",
  )
  echo notation.parse_battle_state(
    "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020",
  )
}
