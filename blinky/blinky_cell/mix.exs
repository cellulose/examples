defmodule BlinkyCell.Mixfile do

  use Mix.Project

  def project, do: [
    app: :blinky_cell,
    version: version,
    elixir: "~> 1.0",
    deps: deps
  ]

  def application, do: [
    applications: [:leds, :hub, :jrtp_bridge, :ethernet, :firmware, :discovery],
    mod: {BlinkyCell, [:leds]}
  ]

  defp deps, do: [
    { :exrm, "~> 0.15.0" },
    { :leds, github: "cellulose/leds"},
    { :hub, github: "cellulose/hub" },
    { :jrtp_bridge, github: "cellulose/jrtp_bridge" },
    { :ethernet, github: "cellulose/ethernet" },
    { :firmware, github: "cellulose/firmware" },
    { :discovery, github: "cellulose/discovery" }
  ]

  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end

end
