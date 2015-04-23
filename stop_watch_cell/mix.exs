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
      applications: [ :hub, :jrtp_bridge, :cowboy, :leds, :ethernet, :discovery,
                      :logger_multicast_backend ],
      env:          [ ]
  ]

  defp deps(:test), do: deps(:dev) ++ [
      { :httpotion, github: "myfreeweb/httpotion"}
  ]

  defp deps(_), do: [
    { :exrm, "~> 0.15.0" },
    { :leds, github: "cellulose/leds"},
    { :hub, github: "cellulose/hub" },
    { :cowboy, "~> 1.0" },
    { :jrtp_bridge, github: "cellulose/jrtp_bridge" },
    { :ethernet, github: "cellulose/ethernet" },
    { :discovery, github: "cellulose/discovery" },
    { :logger_multicast_backend, github: "cellulose/logger_multicast_backend"}
  ]

end
