# frozen_string_literal: true

require 'singleton'
require_relative 'redis'

module Quiq
  class Config
    include Singleton

    attr_accessor :queues
    attr_writer :logger

    def redis=(server)
      @redis = Redis.new(server)
    end

    def redis
      @redis ||= Redis.new
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
