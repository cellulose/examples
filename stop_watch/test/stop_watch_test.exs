defmodule StopWatchTest do

  @http_port 8088
  @cell_prefix :
  @stop_watch_prefix :watch
  @http_path "localhost:#{@http_port}/#{@cell_prefix}/#{@stop_watch_prefix}/"

  use ExUnit.Case
  #{:ok, _} = Application.start Stopwatch.Application
  HTTPotion.start

  test "stop_watch http up running with correct initial state" do
    http_set_stop_watch resolution: 10
    watch = http_get_stop_watch  
    assert watch[:ticks] == 0
    assert watch[:msec] == 0
    assert watch[:resolution] == 10
    assert watch[:running] == false

    assert 0 == StopWatch.GenServer.time(:stop_watch)
    
    # tell it to go via the genserver interface then see that it did as such
    # by looking at the http state

    :ok = GenServer.cast :stop_watch, :go
    :timer.sleep 100
    watch = http_get_stop_watch  
    assert_min_max watch[:ticks], 8, 20
    assert_min_max watch[:msec], 80, 200
    assert watch[:resolution] == 10
    assert watch[:running] == true

    :ok = GenServer.cast :stop_watch, :stop
    :timer.sleep 300
    watch = http_get_stop_watch  
    assert_min_max watch[:ticks], 8, 200
    assert_min_max watch[:msec], 80, 200
    assert watch[:running] == false

    :ok = GenServer.cast :stop_watch, :clear
    watch = http_get_stop_watch  
    assert watch[:ticks] == 0
    assert watch[:msec] == 0

    # use the http interface to set the resolution to 100 and verify that it
    # actually did that.
    http_set_stop_watch resolution: 100 
    watch = http_get_stop_watch 
    assert watch[:resolution] == 100
    assert watch[:ticks] == 0
    assert watch[:msec] == 0
    assert watch[:running] == false
   
    # start it and let it run for 200ms, then verify it reports something 
    # within 1 tick of 200ms

    http_set_stop_watch running: true
    :timer.sleep 300
    watch = http_get_stop_watch
    assert watch[:resolution] == 100
    assert watch[:running] == true
    assert_min_max watch[:ticks], 2, 4
    assert_min_max watch[:msec], 200, 400

    http_set_stop_watch resolution: 10
    watch = http_get_stop_watch
    assert watch[:resolution] == 10
    assert_min_max watch[:ticks], 20, 40
    assert_min_max watch[:msec], 200, 400

    http_set_stop_watch running: false, resolution: 100
    watch = http_get_stop_watch
    assert watch[:resolution] == 100
    assert watch[:running] == false
    assert_min_max watch[:ticks], 2, 4
    assert_min_max watch[:msec], 200, 400
  end

  defp assert_min_max(value, min, max) do
    assert value >= min
    assert value <= max
  end

  # helper to get the stopwatch interface via http
  defp http_get_stop_watch do
    resp = HTTPotion.get @http_path
    #IO.puts "HUB: " <> inspect :hub.dump
    #IO.puts "BODY: " <> resp.body
    assert resp.status_code == 200
    assert {:ok, vhdr} = header resp, "x-version"
    _iver = iver(vhdr)
    assert {:ok, "application/json"} = header resp, "content-type"
    jterm(resp)
  end

  # helper to set the stopwatch interface via http
  defp http_set_stop_watch(dict) do
    set_body = :jrtp_bridge.erl_to_json(dict)
    headers = ["Content-Type": "application/json"]
    #IO.puts "\nWRITING PUT\n" <> set_body
    resp = HTTPotion.put @http_path, set_body, headers
    assert resp.status_code == 202
    #IO.write inspect :hub.dump
    #IO.write resp.body
    #assert {:ok, _vers} = header resp, "x-version"
    #assert {:ok, "application/json"} = header resp, "content-type"
  end

  defp header(resp, key) do
    unless is_atom(key) do
      key = String.to_atom(key)
    end
    assert {:ok, result} = Keyword.fetch(resp.headers, key)
    {:ok, result}
  end

  defp iver(vhdr) do
    [_, ver] = String.split(vhdr, ":")
    :erlang.binary_to_integer(ver)
  end

  defp jterm(resp) do
    assert {:ok, "application/json"} = header resp, "content-type"
    :jrtp_bridge.json_to_erl(resp.body)
  end

end

