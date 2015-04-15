defmodule Extract.Mixfile do
  use Mix.Project

  def project do
    [app: :extract,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [#{:excheck, "~> 0.2.1", only: :test},
     {:excheck, github: "sylane/excheck", branch: "keep_exunit_error", only: :test},
     {:triq,    github: "krestenkrab/triq", only: :test}]
  end
end
