require 'bundler/setup'
require 'dino'

class Board
  attr_reader :temp_sensor, :button
  attr_reader :led_red, :led_green, :led_yellow

  def initialize
    @board       = Dino::Board.new(Dino::TxRx::Serial.new)
    @button      = Dino::Components::Button.new(pin: 2, board: @board)
    @temp_sensor = Dino::Components::Sensor.new(pin: 'A0', board: @board)
    @led_red     = Dino::Components::Led.new(pin: 8, board: @board)
    @led_green   = Dino::Components::Led.new(pin: 9, board: @board)
    @led_yellow  = Dino::Components::Led.new(pin: 10, board: @board)

    @led_thread  = nil
  end

  def run
    @button.down do
      puts 'Button released'
      @led_thread.exit if @led_thread
      stop_leds_show
    end

    @button.up do
      puts 'Button pressed'
      puts "TMP36: #{current_temperature} C"
      @led_thread = Thread.new { loop { run_leds_show } }
    end
  end

  def current_temperature
    data = @temp_sensor.value
    voltage = (data.to_f / 1024) * 5
    temperature = (voltage - 0.5) * 100
    temperature.round(2)
  end

  def stop_leds_show
    puts "Board is stopped"
    reset_all_leds
  end

  def run_leds_show(rhythm = 0.3)
    [@led_red, @led_green, @led_yellow].each do |led|
      led.send(:on)
      sleep rhythm
    end

    reset_all_leds
    sleep rhythm
  end

  def reset_all_leds
    [@led_red, @led_green, @led_yellow].each(&:off)
  end
end
