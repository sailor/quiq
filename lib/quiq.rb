# frozen_string_literal: true

require_relative 'quiq/version'
require_relative 'quiq/config'
require_relative 'quiq/server'
require 'async/redis'

module Quiq
  def self.config
    @config ||= Config.new
  end

  def self.redis
    # TODO: make the redis connection configurable
    @redis ||= begin
      endpoint = Async::Redis.local_endpoint
      Async::Redis::Client.new(endpoint)
    end
  end

  def self.run
    Server.instance.run
  end
end
