# frozen_string_literal: true

require_relative 'scheduler_queue'

module Quiq
  class Scheduler
    def self.start
      Async do
        loop do
          serialized_job, scheduled_at = SchedulerQueue.pull

          if serialized_job && time_to_process?(scheduled_at)
            moved = SchedulerQueue.move_to_original_queue(serialized_job)

            next unless moved
          end
        end
      ensure
        Quiq.redis.close
      end
    end

    def self.time_to_process?(scheduled_at)
      scheduled_at.to_f < Time.now.to_f
    end
  end
end
