# frozen_string_literal: true

require 'singleton'
require 'async/redis'
require_relative 'worker'

module Quiq
  class Server
    include Singleton

    def run
      @queues = Quiq.queues.map { |q| "queue:#{q}" }

      self_read, self_write = IO.pipe
      sigs = %w[INT TERM TTIN TSTP]
      sigs.each do |sig|
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        puts "Signal #{sig} not supported"
      end

      Async do 
        polling_task = Async do
          loop do
            job = fetch_one
            Worker.new(job).run
          end
        ensure
          Quiq.redis.close
        end
  
        begin
          while (readable_io = IO.select([self_read]))
            signal = readable_io.first[0].gets.strip

            case signal
            # INT - Ctrl-C in terminal
            # TERM - Termination of Quiq process
            when 'INT', 'TERM'
              raise Interrupt 
            # TSTP - Is used to stop polling new jobs. 
            # Call TSTP and then TERM in order to gracefully shutdown Quiq
            when 'TSTP'
              puts "Stop polling new jobs!"
              polling_task.stop
            end
          end
        rescue Interrupt
          puts "\n Shutting down"
          exit(0)
        end
      end

    end

    def fetch_one
      # BRPOP returns a tuple made of the queue name then the args
      Quiq.redis.brpop(*@queues).last
    end
  end
end
