# liblnm3

[![Package Version](https://img.shields.io/hexpm/v/liblnm3)](https://hex.pm/packages/liblnm3)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/liblnm3/)

```sh
gleam add liblnm3@1
```
```gleam
import liblnm3

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/liblnm3>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Why Gleam?

This library aims to be shared between backend and frontend, using
the same codebase.

First prototypes were made in C, with WASM in mind. But C brought
lots complexity due to the nature of the lib, mostly strings and lists
manipulations. As the code was growing, I feared it would be hard to
understand for the game community, as I want the logics behind the
engine to be easy to read and even contribute to.

I needed performance, but not necessarily bare metal performance. This is
not ultrabullet chess. LNM game actions are still asynchronous. So I needed
something more high-level, and yet somehow fast.

I had some candidates:

- Rust: love its reliability, love its tooling, love its ecosystem, I use it
  for pro, but… I don’t really like writing it, and it would be very hard to
  read for someone not used to it. It’s ugly, let’s say it. (: Not for a
  personal project.
- Julia: love it as a language, love first-class multiple dispatch, but tooling
  not so great and ecosystem is messy, doc and online resources are messy, and
  sometimes difficult to debug when doing more than crushing numbers in a Jupyter
  Notebook (performance pitfalls, hidden memory allocations, etc.)
- Elixir: nothing bad to say, Elixir is the dope. But the functional paradigm
  could make it hard to adopt for community and enthusiastic
  contributors.
- Node/Bun: It’s directly JS so no need for WASM, that’s part of my main pro
  stack, and I don’t hate it as a language/techno, kinda even like it, but…
  ecosystem is unstable hell and I want to keep long-run personal projects far
  from this mess.
- Crystal: excellent candidate, having very good perf, WASM support,
  readiblity. I use it for pro and like writing it.

But I eventually stopped on Gleam. Because:

- Fast enough.
- Erlang/Elixir ecosystem.
- Killer pipeline operator `|>`. Won on Crystal.
- Compile to JavaScript so no need for WASM.
- Imperative paradigm, clear syntax and garbage
  collection make it easy to read for uninitiated users.
  Won on Elixir.
- Excellent tooling, kinda like Rust’s Cargo.
- Good IDE support.
- No OOP.
- Hype + stability: while new, this techno can safely
  grow without the risk of becoming a ghost land like D or Nim,
  since it will always be backed by the very alive and stable
  BEAM ecosystem, so I’m not afraid of investing time and commit
  a project in it.
