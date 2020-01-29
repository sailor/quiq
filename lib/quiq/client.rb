# frozen_string_literal: true

require 'json'
require 'uri'

module Quiq
  class Client
    def push(job)
      serialized = JSON.dump(job.serialize)
      Async do
        Quiq.redis.lpush(Quiq::Config::DEFAULT_QUEUE_NAME, serialized)
      end
    end

    def self.push(job)
      new.push(job)
    end
  end
end
