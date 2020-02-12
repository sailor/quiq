# frozen_string_literal: true

require 'singleton'

module Quiq
  class Scheduler
    include Singleton

    SCHEDULER_KEY = 'quiq:schedule'

    def start
      # Set the process name
      Process.setproctitle('quiq scheduler')

      Async do
        loop do
          sleep 0.1

          # TODO: use ZRANGEBYSCORE instead to batch enqueuing
          job, scheduled_at = Quiq.redis.zrange(
            SCHEDULER_KEY, 0, 0, with_scores: true
          )

          enqueue(job) if job && scheduled_at.to_f <= Time.now.to_f
        end
      ensure
        Quiq.redis.close
      end
    end

    def self.enqueue_at(job, scheduled_at)
      Quiq.redis.zadd(SCHEDULER_KEY, scheduled_at, job)
    end

    private

    # Push the job in its queue and remove from scheduler_queue
    def enqueue(job)
      Async do
        begin
          payload = JSON.parse(job)
        rescue JSON::ParserError => e
          Quiq.logger.warn("Invalid format: #{e}")
          Queue.send_to_dlq(job)
        end

        puts "job payload: #{payload}"
        Quiq.redis.transaction do |multi|
          multi.lpush(Queue.formatted_name(payload['queue_name']), job)
          multi.zrem(SCHEDULER_KEY, job)
        end
      end.wait
    end
  end
end
