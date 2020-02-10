# frozen_string_literal: true

require_relative 'quiq/version'
require_relative 'quiq/config'
require_relative 'quiq/server'
require_relative 'quiq/client'
require 'async/redis'

module Quiq
  extend self

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
    configuration.parse_options(**options)

    # Load the workers source code
    path = configuration.path
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
