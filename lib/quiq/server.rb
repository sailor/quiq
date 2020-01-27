require 'singleton'
require 'async/redis'
require_relative 'job_wrapper'

module Quiq
  class Server
    include Singleton

    def run
      Async do
        loop do
          data = Quiq.redis.brpop(Quiq.config.queue)
          JobWrapper.new(data.last).run
        end
      ensure
        Quiq.redis.close
      end
    end
  end
end
