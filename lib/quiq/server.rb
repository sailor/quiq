# frozen_string_literal: true

require 'singleton'
require 'async/redis'
require_relative 'job_wrapper'

module Quiq
  class Server
    include Singleton

    def run
      Async do
        loop do
          job = fetch_one
          JobWrapper.new(job).run
        end
      ensure
        Quiq.redis.close
      end
    end

    def fetch_one
      # BRPOP returns a tuple made of the queue name then the args
      Quiq.redis.brpop(Quiq::Config::DEFAULT_QUEUE_NAME).last
    end
  end
end
