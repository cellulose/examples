defmodule BlinkyCell do

  require Logger
  
  #Discovery.start     # must be started after ethernet
  
  def start(_type, _args) do
    Logger.info "Starting BlinkyCell"
    Logger.flush
    Logger.info "Starting Firmware"
    Firmware.start      # always start firmware first
    Logger.flush
    Ethernet.start
    Logger.flush
    {:ok, self}
    #blink_forever
  end
  
  def blink_forever do
    Leds.set red: true, green: false
    :timer.sleep 100
    Leds.set red: false, green: true
    :timer.sleep 100
    blink_forever
  end
  
end
