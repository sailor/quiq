# frozen_string_literal: true

require 'json'

module Quiq
  class JobWrapper
    def initialize(job)
      # TODO: handle deserialization errors
      @job = JSON.parse(job) rescue nil
    end

    def run
      return if @job.nil?

      Async do
        klass = Object.const_get(@job['wrapped'])
        args = @job['args'].first['arguments']
        klass.new.perform(*args)
      end
    end
  end
end
