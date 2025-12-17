import birl
import liblnm3/notation
import prng/random
import prng/seed

/// Solve a battle from an initial battle state notation,
/// and return a battle log.
pub fn solve_battle(initial_state: String) -> String {
  let s = birl.now() |> birl.to_unix_micro() |> seed.new()
  //  let #(who_strikes_first, _) = random.int(0, 1) |> random.sample(s)
  let generator = random.int(0, 1)
  let who_strikes_first = random.sample(generator, s)
  echo who_strikes_first

  "Salut"
  //  let random_value: Float = random.sample(generator)

  //  echo who_starts
}
