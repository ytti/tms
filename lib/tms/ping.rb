module TMS
  class Ping

    INTERVAL = 60*5
    SAMPLES  = 5
    TIMEOUT  = 0.25

    require 'net/ping'

    def initialize event
      @event = event
      main_loop
    end

    def main_loop
      loop do
        ping DB::Device.map
        sleep INTERVAL
      end
    end

    def ping devices
      icmp = Net::Ping::ICMP.new(nil, nil, TIMEOUT)
      devices.each do |device|
        begin
          result = SAMPLES.times.map { icmp.ping device[:ip] }
        rescue Errno::ENETUNREACH
          result = []
        end
        up = result.include?(true)
        if device[:up] != up
          @event << { :type => :ping, :up => up, :device => device, :time => Time.now.utc }
        end
      end
    end

  end
end
