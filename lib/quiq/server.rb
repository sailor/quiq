# frozen_string_literal: true

require 'singleton'
require 'async/redis'
require_relative 'worker'

module Quiq
  class Server
    include Singleton

    def run
      @queues = Quiq.queues.map { |q| "queue:#{q}" }

      # Launch one worker per queue
      @queues.each do |queue|
        fork { Worker.new(queue).start }
      end

      # TODO: handle graceful shutdowns
      Process.waitall
    end
  end
end
