# frozen_string_literal: true

require_relative 'processor'

module Quiq
  class Worker
    def initialize(queue)
      @queue = queue
    end

    def start
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

    def fetch_one
      # BRPOPLPUSH pops a job from the working queue
      # then put it in a processing queue to ensure
      # an "at least once" behaviour
      Quiq.redis.brpoplpush(@queue, "#{@queue}:processing", 0).last
    end
  end
end
