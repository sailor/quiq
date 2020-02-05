# frozen_string_literal: true

require_relative 'processor'

module Quiq
  class Worker
    def initialize(queue)
      @queue = queue
    end

    def start
      Async do
        loop do
          job = fetch_one
          Processor.new(job).run
        end
      ensure
        Quiq.redis.close
      end
    end

    def fetch_one
      # BRPOP returns a tuple made of the queue name then the args
      Quiq.redis.brpop(@queue).last
    end
  end
end
