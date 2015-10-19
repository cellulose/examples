defmodule StopWatch.Application do

  use Application
  
  alias Nerves.Hub

  @http_port 8088
  @cell_prefix :cell
  @stop_watch_prefix :watch
  @http_path "localhost:#{@http_port}/#{@cell_prefix}/#{@stop_watch_prefix}/"

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    dispatch = :cowboy_router.compile([	{:_, [
      {"/#{@cell_prefix}/[...]", JrtpBridge, %{}},
      {"/[...]", :cowboy_static, {:priv_dir, :stop_watch, "web", [{:mimetypes, :cow_mimetypes, :all}]}},
    ]} ])
    {:ok, _pid} = :cowboy.start_http(:http, 10, [port: @http_port],
      [env: [dispatch: dispatch] ])

    # startup the StopWatch.GenServer (which will populate the Echo Hub)

    children = [
      worker(StopWatch.GenServer, [startup_params], [name: :stop_watch])
    ]
    opts = [strategy: :one_for_one, name: StopWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp startup_params, do: %{
    ticks: 0,
    running: false,
    resolution: 100,
    initializer: fn() ->
      Hub.update([@stop_watch_prefix], [running: false])
      Hub.manage([@stop_watch_prefix], [])
    end,
    announcer: &(Hub.update([@stop_watch_prefix], &1))
  }

end

defmodule StopWatch.GenServer do

  @moduledoc """
  A simple stopwatch genserver used for demonstrating atonomous genservers
  in elixir that can be optionally bound to cell.   This is a common pattern.

  Implements a basic counter with configurable resolution
  (down to 1ms).  Implements "go", "stop", and "clear" functions.  Also
  implements a "time" genserver call, to return the number of ms passed.
  Also takes a "resolution" parameter (in ms).
  """
  use GenServer

  @public_state_keys [:ticks, :msec, :resolution, :running]

  def start_link(params, _options \\ []) do
    # REVIEW WHY NEED NAME HERE?  Why can't pass as option?
    GenServer.start_link __MODULE__, params, name: :stop_watch
  end

  def init(state \\ nil) do
    default_state=%{ tref: nil, ticks: 0, running: false, resolution: 10,
                    announcer: (fn(_)->:ok end) }
    {initializer, state} = Dict.pop state, :initializer, :nil
    if initializer, do: initializer.()
    state = Dict.merge(default_state, state)
    announce(state)

    # setup config
    :ets.new :config, [:set, :public, :named_table]
		:ets.insert :config, usn: "2f20202faf02"

    {:ok, tref} = :timer.send_after(state.resolution, :tick)
    {:ok, %{state | tref: tref}}
  end

  # simple client api

  @doc "start the stopwatch"
  def go(pid),    do: GenServer.cast(pid, :go)

  @doc "stop the stopwatch"
  def stop(pid),  do: GenServer.cast(pid, :stop)

  @doc "clear the time on the stopwatch"
  def clear(pid), do: GenServer.cast(pid, :clear)

  @doc "get the current time of the stopwatch"
  def time(pid),  do: GenServer.call(pid, :time)

  # public (server) genserver handlers, which modify state

  def handle_cast(:go, state) do
    {:ok, tref} = :timer.send_after(state.resolution, :tick)
    new_state = %{state | running: true, tref: tref}
    announce(new_state)
    {:noreply, new_state}
  end

  def handle_cast(:stop, state) do
    new_state = %{state | running: false}
    announce(new_state)
    {:noreply, new_state}
  end

  def handle_cast(:clear, state) do
    new_state = %{state | ticks: 0}
    announce(new_state)
    {:noreply, new_state}
  end

  def handle_call(:time, _from, state) do
    {:reply, state.ticks, state}
  end

  # request handler (cell compatible)

  def handle_call({:request, _path, changes, _context}, _from, old_state) do
    new_state = Enum.reduce changes, old_state, fn({k,v}, state) ->
      handle_set(k,v,state)
    end
    {:reply, :ok, new_state}
  end

  # handle setting "running" to true or false for go/stop (cell)
  def handle_set(:running, true, state) do
    if not state.running do
      cancel_any_current_timer(state)
      {:ok, tref} = :timer.send_after(state.resolution, :tick)
      announce %{state | running: true, tref: tref}
    else
      state
    end
  end

  def handle_set(:running, false, state) do
    if state.running do
      cancel_any_current_timer(state)
      announce %{state | running: false, tref: nil}
    else
      state
    end
  end

  # handle setting "ticks" to zero to clear (cell)
  def handle_set(:ticks, 0, state) do
    new_state = %{state | ticks: 0}
    announce(new_state)
  end


  # handle setting "resolution" (cell)
  # changes the resolution of the stopwatch.  Try to keep the current time
  # by computing a new tick count based on the new offset, and cancelling
  # timers.   Returns a new state
  def handle_set(:resolution, nr, state) do
    cur_msec = state.ticks * state.resolution
    cancel_any_current_timer(state)
    {:ok, tref} = :timer.send_after(nr, :tick)
    new_state = %{state | resolution: nr, ticks: div(cur_msec,nr), tref: tref}
    announce new_state
  end

  # catch-all for handling bogus properties

  def handle_set(_, _, state), do: state

  # internal (timing) genserver handlers

  def handle_info(:tick, state) do
    if state.running do
      {:ok, tref} = :timer.send_after(state.resolution, :tick)
      new_state = %{state | ticks: (state.ticks + 1), tref: tref}
      announce_time_only(new_state)
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  # private helpers

  # cancel current timer if present, and set timer ref to nil
  defp cancel_any_current_timer(state) do
    if (state.tref) do
      {:ok, :cancel} = :timer.cancel state.tref
    end
    %{state | tref: nil}
  end

  # announce functions (cell compatible) - returns passed
  defp announce(state) do
    elements_with_keys(state, @public_state_keys)
    |> Dict.merge(msec: (state.ticks * state.resolution))
    |> state.announcer.()
    state
  end

  defp announce_time_only(state) do
    state.announcer.(
      ticks: state.ticks,
      msec:  (state.ticks * state.resolution)
    )
    state
  end

  # returns dict of elemnts from source_dict that have keys in valid_keys

  defp elements_with_keys(source_dict, valid_keys) do
    Enum.filter source_dict, fn({k, _v}) ->
      Enum.member?(valid_keys, k)
    end
  end

end
