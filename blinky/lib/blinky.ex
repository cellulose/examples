defmodule Blinky do

  def start(_type, _args) do
    blink_forever
  end
  
  def blink_forever do
    Leds.set red: true, green: false
    :timer.sleep 100
    Leds.set red: false, green: true
    :timer.sleep 100
    blink_forever
  end

end
