defmodule Battle.MixProject do
  use Mix.Project

  def project do
    [
      app: :battle,
      name: "battle",
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/akisroc/lnm3",
      docs: [
        main: "akisroc/lnm3",
        extras: ["README.md", "LICENSE"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {
        :ex_doc,
        "~> 0.34",
        only: :dev,
        runtime: false,
        warn_if_outdated: true,
        extras: ["README.md", "LICENSE"]
      }
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
