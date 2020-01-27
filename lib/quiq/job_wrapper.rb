# frozen_string_literal: true

require 'json'
require_relative 'test_job' # TODO: remove this dependency

module Quiq
  class JobWrapper
    def initialize(item)
      # TODO: handle deserialization errors
      @item = JSON.parse(item) rescue nil
    end

    def run
      return if @item.nil?

      Async do
        klass = Object.const_get(@item['wrapped'])
        args = @item['args'].first['arguments']
        klass.new.perform(*args)
      end
    end
  end
end
