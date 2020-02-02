# frozen_string_literal: true

require 'singleton'
require 'async/container'
require 'async/redis'
require_relative 'worker'

module Quiq
  class Server < Async::Container::Controller
    include Singleton

    # Called by Server.instance.run
    def setup(container)
      @queues = Quiq.queues.map { |q| "queue:#{q}" }

      container.async do
        loop do
          job = fetch_one
          Worker.new(job).run
        end
      ensure
        Quiq.redis.close
      end
    end

    def fetch_one
      # BRPOP returns a tuple made of the queue name then the args
      Quiq.redis.brpop(*@queues).last
    end
  end
end
