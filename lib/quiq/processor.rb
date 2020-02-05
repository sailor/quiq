# frozen_string_literal: true

require 'json'

module Quiq
  class Processor
    def initialize(job)
      # TODO: handle deserialization errors
      @job = JSON.parse(job) rescue nil
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
