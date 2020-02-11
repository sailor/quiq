# frozen_string_literal: true

require 'json'
require 'uri'

module Quiq
  class Client
    def push(job, scheduled_at)
      serialized = JSON.dump(job.serialize)
      queue = Queue.new(job.queue_name)

      if scheduled_at
        Async { SchedulerQueue.push(serialized, scheduled_at) }
      else
        Async { queue.push(serialized) }
      end
    end

    def self.push(job, scheduled_at: nil)
      new.push(job, scheduled_at)
    end
  end
end
