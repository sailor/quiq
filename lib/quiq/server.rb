# frozen_string_literal: true

require 'singleton'
require 'async/redis'
require_relative 'worker'

module Quiq
  class Server
    include Singleton

    def run
      Async do
        loop do
          job = fetch_one
          Worker.new(job).run
        end
      ensure
        Quiq.redis.close
      end
    end

    def fetch_one
      queues = Quiq.queues.map {|q| "queue:#{q}"}
      # BRPOP returns a tuple made of the queue name then the args
      Quiq.redis.brpop(*queues).last
    end
  end
end
