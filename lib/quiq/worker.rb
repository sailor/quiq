# frozen_string_literal: true

require_relative 'processor'

module Quiq
  class Worker
    def initialize(queue)
      @queue = queue
      @processing_queue = "#{@queue}:processing"
    end

    def start
      # Purge the processing queue by re-enqueing
      # messages that weren't fully processed
      # beware that your jobs must be idempotent!
      purge_processing_queue!

      # Then start processing enqueued jobs
      Async do
        loop do
          job = fetch_one
          Processor.new(job).run
          Quiq.redis.lrem(@queue, 1, job)
        end
      ensure
        Quiq.redis.close
      end
    end

    private

    def fetch_one
      # BRPOPLPUSH pops a job from the working queue
      # then put it in a processing queue to ensure
      # an "at least once" behaviour
      Quiq.redis.brpoplpush(@queue, @processing_queue, 0).last
    end

    # Insert elements that weren't fully processed
    # at the tail of the queue to avoid loss
    # Note that they should be enqueued at the head
    # of the queue, but Redis lacks a LPOPRPUSH command
    def purge_processing_queue!
      task = Async do
        Quiq.redis.pipeline do |pipe|
          loop do
            job = pipe.sync.call('RPOPLPUSH', @processing_queue, @queue)
            break if job.nil?
          end
          pipe.close
        end
      end

      task.wait
    end
  end
end
