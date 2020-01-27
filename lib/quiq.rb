# frozen_string_literal: true

require_relative 'quiq/version'
require_relative 'quiq/config'
require_relative 'quiq/server'
require 'async/redis'

module Quiq
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Config.new
    yield(configuration) if block_given?
  end

  def self.redis
    configure if configuration.nil?

    @redis ||= begin
      endpoint = Async::Redis.local_endpoint
      Async::Redis::Client.new(endpoint)
    end
  end

  def self.run
    Server.instance.run
  end
end
