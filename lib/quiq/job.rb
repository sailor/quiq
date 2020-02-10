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

          # Then load the definition of the job + its arguments
          klass = Object.const_get(payload['job_class'])
          args = payload['arguments']

          # Then run the task
          klass.new.perform(*args)
        rescue JSON::ParserError => exception
          Quiq.logger.warn("Invalid format: #{exception.to_s}")
          send_to_dlq(payload, exception)
        rescue Exception => exception
          Quiq.logger.debug("Sending message to DLQ: #{exception.to_s}")
          send_to_dlq(payload, exception)
        ensure
          # Remove the job from the processing list
          Queue.delete(@queue.processing, @raw)
        end
      end
    end

    private

    def send_to_dlq(payload, exception)
      if payload
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
