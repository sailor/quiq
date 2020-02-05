# frozen_string_literal: true

class TestJob < ApplicationJob
  def perform(data, wait)
    puts "[Worker ##{$$}] Receiving new job: #{data}"
    Quiq.current_task.sleep wait
    puts "[Worker ##{$$}] Time to wake up after #{wait} seconds"
  end
end
