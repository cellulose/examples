use Mix.Config

# led mapping configuration for raspberry pi:
config :leds, name_map: [ red: "led0", green: "led1" ]

config :logger,
        backends: [ :console, LoggerMulticastBackend ],
        level: :debug,
        format: "$time $metadata[$level] $message\n"
        