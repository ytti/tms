module TMS
  class AlarmHandler
    require 'tms/udp'
    require 'tms/mail'

    def initialize
      @udp    = UDP.new
      @mail   = Mail.new
      #@mq    = TDCMQ.new
      @alarms = [@udp, @mail]
    end

    def linkchange device, int, up
      desc = int[:description].to_s
      desc = '(' + desc + ') ' if desc.size > 0
      msg = "%s %s@ %s" % [int[:name], desc, device[:name]]
      alarm msg, up
    end

    def ping device, up
      msg = "%s" % [device[:name]]
      alarm msg, up
    end

    def reload device
      msg = "%s reloaded" % [device[:name]]
      alarm msg, false
    end

    def alarm msg, up
      status = up == true ? 'UP: ' : 'DOWN: '
      msg = status + msg
      @alarms.each do |alarm|
        alarm.alarm msg.dup
      end
    end


    private

  end
end
