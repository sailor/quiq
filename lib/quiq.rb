# frozen_string_literal: true

require_relative 'quiq/version'
require_relative 'quiq/config'
require_relative 'quiq/server'
require_relative 'quiq/client'
require 'async/redis'

module Quiq
  DEFAULT_QUEUE_NAME = 'default'

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Config.instance
    yield(configuration) if block_given?
  end

  def self.redis
    configuration.redis
  end

  def self.run(options)
    configure if configuration.nil?
    configuration.queues = options[:queues] || [DEFAULT_QUEUE_NAME]

    # Lookup for workers in the given path or the current directory
    path = options[:path] || Dir.pwd
    if File.directory?(path)
      Dir.glob(File.join(path, '*.rb')).each { |file| require file }
    else
      require path
    end

    Server.instance.run!
  end

  def self.queues
    configuration.queues
  end

  def self.current_task
    Async::Task.current
  end

  def self.logger
    configuration.logger
  end
end
