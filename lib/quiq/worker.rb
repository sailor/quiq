# frozen_string_literal: true

require_relative 'processor'
require_relative 'queue'

module Quiq
  class Worker
    def initialize(queue)
      @queue = Queue.new(queue)
    end

    def start
      # Purge the processing queue by re-enqueing messages that weren't fully processed
      # Beware that the jobs must be idempotent!
      @queue.purge_processing!

      # Then start processing enqueued jobs
      Async do
        loop do
          job = @queue.pop
          Processor.new(job).run
          Quiq.redis.lrem(@queue.processing, 0, job)
        end
      ensure
        Quiq.redis.close
      end
    end
  end
end
