# frozen_string_literal: true

require 'json'

module Quiq
  class Job
    def initialize(raw, queue)
      @raw = raw
      @queue = queue
    end

    def run
      Async do
        begin
          # First parse the raw message from redis
          payload = JSON.parse(@raw)

          # Then load the definition of the job + deserialize it to a job object
          klass = Object.const_get(payload['job_class'])
          job = klass.deserialize(payload)

          # Then run the task
          job.perform_now
        rescue JSON::ParserError => e
          Quiq.logger.warn("Invalid format: #{e}")
          send_to_dlq(@raw, e)
        rescue StandardError => e
          Quiq.logger.debug("Sending message to DLQ: #{e}")
          send_to_dlq(payload, e)
        ensure
          # Remove the job from the processing list
          Queue.delete(@queue.processing, @raw)
        end
      end
    end

    private

    def send_to_dlq(payload, exception)
      if payload.is_a?(Hash)
        payload['error'] = exception.to_s
        payload['backtrace'] = exception.backtrace
        message = JSON.dump(payload)
      else
        message = @raw
      end

      Queue.send_to_dlq(message)
    end
  end
end
