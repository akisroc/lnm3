# Liblnm3

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `liblnm3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:liblnm3, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/liblnm3>.

## Why Elixir?

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
- Node/Bun: it’s directly JS so the lib could be shared with frontend without WASM.
  Also Node is part of my main pro stack, and I don’t hate it as a language/techno,
  kinda even like it, but… ecosystem is unstable hell and I want to keep long-run
  personal projects far from this mess.
- Crystal: excellent candidate, having very good perf, stable WASM support,
  readiblity. I use it for pro and like writing it.
- Gleam: young, promising, runs on BEAM, excellent tooling. Kind of a
  high level Rust. And compiles to JavaScript, which is its killer feature,
  I believe. But compiling to JavaScript would cut me from the stable
  Erlang/Elixir ecosystem, which is a dangerous bet. So I didn’t really see
  the point in using it instead of Erlang or Elixir.
- Elixir: well, Elixir is the dope!

So I stopped on Elixir. Because:

- Fast enough.
- Erlang/Elixir ecosystem is paradise.
- Killer pipeline operator `|>`. Won on Crystal.
- Clear, high level rubyish syntax, and garbage collection, make
  it easy to read for uninitiated users.
- Excellent tooling, all hail Mix.
- Good and well maintained IDE/editor support with LSP.
- Stability: Erlang/Elixir is niche, but a solid niche, running
  behind Discord, Whatsapp, Spotify, etc. It will never become a
  ghost unmaintained land like less loved niches (D, Nim, etc.),
  so I’m not afraid of investing time and commit a project in it.