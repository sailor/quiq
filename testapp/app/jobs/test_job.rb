# frozen_string_literal: true

class TestJob < ApplicationJob
  class CustomError < StandardError; end

  retry_on(CustomError, wait: 5, attempts: 3, queue: :retry) do
    raise
  end

  def perform(data, wait)
    puts "[Worker ##{$$}] Receiving new job: #{data}"
    Quiq.current_task.sleep wait
    puts "[Worker ##{$$}] Time to wake up after #{wait} seconds"
    raise CustomError, 'Caught CustomError'
  end
end
