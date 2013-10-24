require 'tms/log'
require 'tms/config'
require 'tms/db'
require 'tms/event_handler'
require 'tms/periodic'
require 'tms/snmp'
require 'tms/trap'
require 'tms/ping'
require 'pp'

module TMS

  class Core

    LOOP_SLEEP = 0.1

    private

    def initialize
      @eh = EventHandler.new
      treads = run_threads
      main_loop
    end

    def main_loop
      loop do
        @eh.run
        sleep LOOP_SLEEP
      end
    end

    def run_threads
      Thread.abort_on_exception = true
      threads = []
      threads << Thread.new { Trap.new @eh.trap }
      threads << Thread.new { Ping.new @eh.ping }
      threads << Thread.new { Periodic.new @eh.poll }
      threads
    end

  end

end
