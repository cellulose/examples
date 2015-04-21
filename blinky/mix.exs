defmodule Blinky.Mixfile do
  use Mix.Project

  def project do
    [app: :blinky,
     version: version,
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:leds],
     mod: {Blinky, [:leds]}]
  end

  defp deps, do: [
    { :exrm, "~> 0.15.0" },
    { :leds, github: "cellulose/leds"}
  ]

  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end
end
