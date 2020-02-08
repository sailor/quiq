# frozen_string_literal: true

require 'json'

module Quiq
  class Job
    def initialize(raw)
      @raw = raw
    end

    def run
      begin
        # First parse the raw data from redis
        datas = JSON.parse(@raw)

        # Then load the definition of the job + its arguments
        klass = Object.const_get(datas['job_class'])
        args = datas['arguments']
        queue = datas['queue_name']

        # Then run the task asynchronously
        Async { klass.new.perform(*args) }
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
