# frozen_string_literal: true

# Monkey patch activejob until there is an official integration
module ActiveJob
  module QueueAdapters
    class QuiqAdapter
      def enqueue(job)
        Quiq::Client.push(job)
      end

      def enqueue_at(job, timestamp)
        raise NotImplementedError, 'Support for schedule jobs is coming soon.'
      end

      class JobWrapper
        class << self
          def perform(job_data)
            Base.execute job_data
          end
        end
      end
    end
  end
end

Quiq.configure do |config|
  config.redis = 'redis://localhost:6379'
  # config.logger = Rails.logger
end
