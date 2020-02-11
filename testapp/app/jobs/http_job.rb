# frozen_string_literal: true

require 'uri'
require 'async/http/internet'

class HttpJob < ApplicationJob
  def perform(url)
    uri = URI(url)

    client = Async::HTTP::Internet.new
    response = client.get(url)
    Quiq.logger.info response.read
  end
end
