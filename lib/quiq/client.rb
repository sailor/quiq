# frozen_string_literal: true

require 'json'
require 'uri'

module Quiq
  class Client
    def push(job)
      serialized = JSON.dump(job.serialize)
      queue = Queue.new(job.queue_name)

      Async do
        queue.push(serialized)
      end
    end

    def self.push(job)
      new.push(job)
    end
  end
end
