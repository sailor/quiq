# frozen_string_literal: true

require 'json'

module Quiq
  class Job
    def initialize(raw)
      @raw = raw
    end

    def run
      Async do
        begin
          # First parse the raw data from redis
          message = JSON.parse(@raw)

          # Then load the definition of the job + its arguments
          klass = Object.const_get(message['job_class'])
          args = message['arguments']
          queue = message['queue_name']

          # Then run the task asynchronously
          klass.new.perform(*args)
        rescue JSON::ParserError
          Quiq.logger.error("Invalid format: #{$!}")
        rescue Exception => e
          # TODO: send the dead job in a DLQ
        ensure
          # Remove the job from the processing list
          Queue.delete(Queue.processing_name(queue), @raw)
        end
      end
    end
  end
end
