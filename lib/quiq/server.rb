# frozen_string_literal: true

require 'singleton'
require 'async/redis'
require_relative 'worker'
require_relative 'scheduler'

module Quiq
  class Server
    include Singleton

    def run!
      # Launch one worker per queue
      Quiq.queues.each do |queue|
        fork { Worker.new(queue).start }
      end

      # Launch scheduler for jobs to be performed at certain time
      fork { Scheduler.instance.start }

      # Set the process name
      Process.setproctitle("quiq master #{Quiq.configuration.path}")

      # TODO: handle graceful shutdowns
      Process.waitall
    end
  end
end
