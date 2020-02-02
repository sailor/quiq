# frozen_string_literal: true

require_relative 'quiq/version'
require_relative 'quiq/config'
require_relative 'quiq/server'
require_relative 'quiq/client'
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
    configuration.redis
  end

  def self.run(options)
    configure if configuration.nil?
    self.configuration.queues = options[:queues] || ['default']

    Server.instance.run
  end

  def self.current_task
    Async::Task.current
  end
end
