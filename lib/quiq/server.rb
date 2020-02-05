# frozen_string_literal: true

require 'singleton'
require 'async/container'
require 'async/redis'
require_relative 'worker'

module Quiq
  class Server
    include Singleton

    # Called by Server.instance.run
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
