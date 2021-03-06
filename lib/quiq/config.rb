# frozen_string_literal: true

require 'logger'
require 'singleton'
require_relative 'redis'

module Quiq
  class Config
    include Singleton

    attr_reader :queues, :path
    attr_writer :logger

    def redis=(server)
      @redis = Redis.new(server)
    end

    def redis
      @redis ||= Redis.new
    end

    def logger
      @logger ||= begin
        level = @log_level || Logger::DEBUG
        ::Logger.new(STDOUT, level: level)
      end
    end

    def parse_options(path:, queues:, log_level:)
      @path = path
      @queues = queues
      @log_level = log_level
    end
  end
end
