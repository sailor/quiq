# frozen_string_literal: true

# Scheduler queue is used to process jobs scheduled for the future.
module Quiq
  class SchedulerQueue
    NAME = 'scheduler_queue'.freeze

    def self.push(serialized_job, scheduled_at)
      Quiq.redis.zadd(NAME, scheduled_at, serialized_job)
    end

    # Reads the job with the nearest timestamp
    def self.pull
      Quiq.redis.zrange(NAME, 0, 0, with_scores: true)
    end

    # Push the job in its queue and remove from scheduler_queue
    def self.move_to_original_queue(serialized_job)
      job = JSON.parse(serialized_job)

      # TODO: Implement fine-grained locking
      pushed = Quiq.redis.lpush("queue:#{job['queue_name']}", serialized_job)

      if pushed <= 0
        Quiq.logger.error("Could not lpush to the queue:#{job['queue_name']}")
        return false
      end

      delete(serialized_job)
    end

    def self.delete(serialized_job)
      Quiq.redis.zrem(NAME, serialized_job)
    end
  end
end
