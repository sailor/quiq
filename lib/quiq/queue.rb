# frozen_string_literal: true

module Quiq
  class Queue
    PREFIX = 'queue'
    PROCESSING_SUFFIX = 'processing'

    attr_reader :processing

    def initialize(name)
      @name = self.class.formatted_name(name)
      @processing = self.class.processing_name(name)
    end

    def push(job)
      Quiq.redis.lpush(@name, job)
    end

    def pop
      Quiq.redis.brpoplpush(@name, @processing, 0)
    end

    # Insert elements that weren't fully processed at the tail of the queue to avoid loss
    # @note that they should be enqueued at the head of the queue, but Redis lacks a LPOPRPUSH command
    def purge_processing!
      task = Async do
        Quiq.redis.pipeline do |pipe|
          loop do
            job = pipe.sync.call('RPOPLPUSH', @processing, @name)
            Quiq.logger.warn("Requeuing job #{job} in #{@name}") unless job.nil?
            break if job.nil?
          end
          pipe.close
        end
      end

      task.wait
    end

    def self.delete(queue, job)
      Quiq.redis.lrem(queue, 0, job)
    end

    def self.formatted_name(name)
      "#{PREFIX}:#{name}"
    end

    def self.processing_name(name)
      "#{PREFIX}:#{name}:#{PROCESSING_SUFFIX}"
    end
  end
end
