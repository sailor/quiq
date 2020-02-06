# frozen_string_literal: true

require 'singleton'
require 'async/redis'
require_relative 'worker'

module Quiq
  class Server
    include Singleton

    def run
      # Launch one worker per queue
      Quiq.queues.each do |q|
        fork { Worker.new("queue:#{q}").start }
      end

      # TODO: handle graceful shutdowns
      Process.waitall
    end
  end
end
