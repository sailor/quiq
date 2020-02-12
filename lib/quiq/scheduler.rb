# frozen_string_literal: true

require 'singleton'
require_relative 'scheduler_queue'

module Quiq
  class Scheduler
    include Singleton

    def start
      # Set the process name
      Process.setproctitle('quiq scheduler')

      Async do
        loop do
          sleep 0.2

          serialized_job, scheduled_at = SchedulerQueue.pop
          next unless serialized_job && time_to_process?(scheduled_at)

          SchedulerQueue.move_to_original_queue(serialized_job)
        end
      ensure
        Quiq.redis.close
      end
    end

    def time_to_process?(scheduled_at)
      scheduled_at.to_f < Time.now.to_f
    end
  end
end
