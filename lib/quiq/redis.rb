# frozen_string_literal: true

require 'uri'

module Quiq
  class Redis
    DEFAULT_REDIS_URL = 'redis://localhost:6379'

    attr_reader :client

    def initialize(server = DEFAULT_REDIS_URL)
      uri = URI(server)
      endpoint = Async::IO::Endpoint.tcp(uri.host, uri.port)
      @client = Async::Redis::Client.new(endpoint)
    end
  end
end
