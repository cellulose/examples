defmodule StopWatch.Mixfile do

  use Mix.Project

  def project, do: [
    app: :stop_watch,
    version: "0.1.0",
    elixir: "~> 1.0",
    deps: deps(Mix.env)
  ]

  def application, do: [
      mod:          { StopWatch.Application, [] },
      applications: [ :nerves_hub, :jrtp_bridge, :cowboy ],
      env:          [ ]
  ]

  defp deps(:test), do: deps(:dev) ++ [
      { :httpotion, github: "myfreeweb/httpotion"}
  ]

  defp deps(_), do: [
    { :discovery, github: "cellulose/discovery" },
    { :jrtp_bridge, github: "cellulose/jrtp_bridge" },
    { :nerves_hub, github: "nerves-project/nerves_hub" }
  ]

end
