# frozen_string_literal: true

module Quiq
  class Queue
    attr_reader :processing

    def initialize(name)
      @name = "queue:#{name}"
      @processing = "#{@name}:processing"
    end

    def fetch_one
      Quiq.redis.brpoplpush(@name, @processing, 0)
    end

    # Insert elements that weren't fully processed at the tail of the queue to avoid loss
    # @note that they should be enqueued at the head of the queue, but Redis lacks a LPOPRPUSH command
    def purge_processing!
      task = Async do
        Quiq.redis.pipeline do |pipe|
          loop do
            job = pipe.sync.call('RPOPLPUSH', @processing, @queue)
            break if job.nil?
          end
          pipe.close
        end
      end

      task.wait
    end
  end
end
