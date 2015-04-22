# TODO

## CRITICAL BUGS

Things don't start.  Seems like Hub should be started automatically becaus eit's referenced as an application.a

    ** (Mix) Could not start application stop_watch: StopWatch.Application.start(:normal, []) returned an error: shutdown: failed to start child: StopWatch.GenServer
        ** (EXIT) exited in: :gen_server.call(:hub, {:update, [:watch], [running: false], []})
            ** (EXIT) no process
        

## SOON

- make this work with Hub and JrtpBridge, not :hub and :jrtp_bridge

## FUTURE IMPROVEMENTS

- add support for discovery