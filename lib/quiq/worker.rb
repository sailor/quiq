# frozen_string_literal: true

require_relative 'job'
require_relative 'queue'

module Quiq
  class Worker
    def initialize(queue)
      @queue = Queue.new(queue)
    end

    def start
      # Re-enqueue messages that weren't fully processed because the worker got killed
      # Beware that the jobs must be idempotent!
      @queue.purge_processing!

      # Then start processing enqueued jobs
      Async do
        loop { Job.new(@queue.pop, @queue).run }
      ensure
        Quiq.redis.close
      end
    end
  end
end
