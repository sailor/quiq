# frozen_string_literal: true

# Scheduler queue is used to process jobs scheduled for the future.
module Quiq
  class SchedulerQueue
    NAME = 'scheduler_queue'

    def self.push(serialized_job, scheduled_at)
      Quiq.redis.zadd(NAME, scheduled_at, serialized_job)
    end

    # Reads the job with the nearest timestamp
    def self.pull
      # TODO: use ZRANGEBYSCORE instead
      Quiq.redis.zrange(NAME, 0, 0, with_scores: true)
    end

    # Push the job in its queue and remove from scheduler_queue
    def self.move_to_original_queue(serialized_job)
      begin
        job = JSON.parse(serialized_job)
      rescue JSON::ParserError => e
        Quiq.logger.warn("Invalid format: #{e}")
        Queue.send_to_dlq(serialized_job)
      end

      # TODO: wrap those 2 calls in a transaction
      Queue.push(job['queue_name'], serialized_job)
      Quiq.redis.zrem(NAME, serialized_job)
    end
  end
end
