# frozen_string_literal: true

module Quiq
  class Queue
    PREFIX = 'queue'
    PROCESSING_SUFFIX = 'processing'
    DEAD_LETTER_QUEUE = 'dead'

    attr_reader :name, :processing

    def initialize(name)
      @name = self.class.formatted_name(name)
      @processing = self.class.processing_name(name)
    end

    def push(job)
      pushed = Quiq.redis.lpush(@name, job)
      return unless pushed <= 0

      Quiq.logger.error("Could not push to the queue: #{@name}")
      false
    end

    def pop
      Quiq.redis.brpoplpush(@name, @processing, 0)
    end

    # Insert elements that weren't fully processed at the tail of the queue to avoid loss
    # @note that they should be enqueued at the head of the queue, but Redis lacks a LPOPRPUSH command
    def purge_processing!
      Async do
        Quiq.redis.pipeline do |pipe|
          loop do
            job = pipe.sync.call('RPOPLPUSH', @processing, @name)
            Quiq.logger.warn("Requeuing job #{job} in #{@name}") unless job.nil?
            break if job.nil?
          end
          pipe.close
        end
      end.wait
    end

    def self.push(queue, job)
      @queue = new(queue)
      @queue.push(job)
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

    def self.send_to_dlq(job)
      @dlq ||= Queue.new(DEAD_LETTER_QUEUE)
      @dlq.push(job)
    end
  end
end
