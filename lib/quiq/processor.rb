# frozen_string_literal: true

require 'json'

module Quiq
  class Processor
    def initialize(job)
      # TODO: handle deserialization errors
      begin
        @job = JSON.parse(job)
      rescue
        Quiq.logger.error "Can't read job: #{job}\n#{$!}"
      end
    end

    def run
      return if @job.nil?

      Async do
        klass = Object.const_get(@job['job_class'])
        args = @job['arguments']
        klass.new.perform(*args)
      end
    end
  end
end
