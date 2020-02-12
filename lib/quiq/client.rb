# frozen_string_literal: true

require 'json'
require 'uri'

module Quiq
  class Client
    def push(job, scheduled_at)
      serialized_job = JSON.dump(job.serialize)

      if scheduled_at
        Async { Scheduler.enqueue_at(serialized_job, scheduled_at) }
      else
        Async { Queue.push(job.queue_name, serialized_job) }
      end
    end

    def self.push(job, scheduled_at: nil)
      new.push(job, scheduled_at)
    end
  end
end
