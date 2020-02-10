# frozen_string_literal: true

require_relative 'quiq/version'
require_relative 'quiq/config'
require_relative 'quiq/server'
require_relative 'quiq/client'
require 'async/redis'

module Quiq
  extend self

  DEFAULT_QUEUE_NAME = 'default'

  def configuration
    Config.instance
  end

  def configure
    yield(configuration) if block_given?
  end

  def redis
    configuration.redis.client
  end

  def boot(options)
    # List of queues to pop jobs from
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

  def queues
    configuration.queues
  end

  def current_task
    Async::Task.current
  end

  def logger
    configuration.logger
  end
end
