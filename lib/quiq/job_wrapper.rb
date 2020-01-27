# frozen_string_literal: true

require 'json'
require_relative 'test_job' # TODO: remove this dependency

module Quiq
  class JobWrapper

    module Extensions
      def self.included(base)
        base.class_eval do
          attr_accessor :task
        end
      end
    end

    def initialize(item)
      # TODO: handle deserialization errors
      @item = JSON.parse(item) rescue nil
    end

    def run
      return if @item.nil?

      Async do |task|
        klass = Object.const_get(@item['wrapped'])
        klass.include(Extensions)
        args = @item['args'].first['arguments']
        job = klass.new
        job.task = task
        job.perform(*args)
      end
    end
  end
end
