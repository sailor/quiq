# frozen_string_literal: true

require 'uri'

module Quiq
  class Config
    DEFAULT_QUEUE_NAME = 'queue:default'

    # Return a connection to the local
    # Redis instance if not configured
    def redis
      @redis ||= begin
        endpoint = Async::Redis.local_endpoint
        Async::Redis::Client.new(endpoint)
      end
    end

    # Only accepts a redis connection uri for now
    # Note the client used is far from being production ready
    def redis=(server)
      uri = URI(server)
      endpoint = Async::IO::Endpoint.tcp(uri.host, uri.port)
      @redis = Async::Redis::Client.new(endpoint)
    end
  end
end
