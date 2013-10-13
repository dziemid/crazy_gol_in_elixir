defmodule Gol.Mixfile do
  use Mix.Project

  def project do
    [ app: :gol,
      version: "0.0.1",
      elixir: "~> 0.10.3",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Gol, [] }]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      {:exactor,"0.1",[github: "sasa1977/exactor"]}
    ]
  end
end
