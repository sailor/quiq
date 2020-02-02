# frozen_string_literal: true

require 'json'
require 'uri'

module Quiq
  class Client
    def push(job)
      serialized = JSON.dump(job.serialize)
      Async do
        Quiq.redis.lpush("queue:#{job.queue_name}", serialized)
      end
    end

    def self.push(job)
      new.push(job)
    end
  end
end
