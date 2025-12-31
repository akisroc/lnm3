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
      extra_applications: [:logger],
      mod: {Battle.Application, []}
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
      },
      {:grpc, "~> 0.11"},
      {:protobuf, "~> 0.14"}
    ]
  end
end
