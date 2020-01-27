# frozen_string_literal: true

class TestJob
  def perform(data, wait)
    puts "Receiving new data: #{data}"
    Quiq.current_task.sleep wait
    puts "Time to wake up after #{wait} seconds"
  end
end
