module TMS
  class EventHandler
    require 'tms/alarm_handler'
    attr_accessor :ping, :trap, :poll

    def initialize
      @ping = []
      @trap = []
      @poll = []
      @ah   = AlarmHandler.new
    end

    def run
      [@ping, @trap, @poll].each do |source|
        while event = source.shift
          event_process event
        end
      end
    end

    private

    def event_process event
      case event[:type]
      when :ping
        event_ping event
      when :linkchange
        event_linkchange event
      when :reload
        event_reload event
      end
    end

    def event_ping event
      up_new, device = event[:up], event[:device]
      DB::Device[device[:id]].update :up => up_new
      add :device_id=>device[:id], :to=>up_new, :time=>event[:time], :type=>'ping'
      @ah.ping device, up_new
    end

    def event_linkchange event
      up     = event[:up]
      index  = event[:index].to_i
      name   = event[:name]
      source = event[:source]
      time   = event[:time]
      device = DB::Device.first(:ip => source)
      unless device
        Log.error "Linkchange trap from unmanaged host %s for %s [%s] to %s" % [source, name, index, up]
      else
        int = DB::Interface.first(:device_id=>device[:id], :name=>name, :index=>index)
        unless int
          Log.error "Linkchange trap from host %s for unmanaged %s [%s] to %s" % [source, name, index, up]
        else

          @ah.linkchange device, int, up
          add :device_id=>device[:id], :interface_id=>int[:id],
              :to=>up, :time=>time, :type=>'linkchange'
          int.update :up => up
        end
      end
    end

    def event_reload event
      source, time = event[:source], event[:time]
      device = DB::Device.first(:ip => source)
      unless device
        Log.error "Reload trap from unmanaged host %s" % [source]
      else
        @ah.reload device
        add :device_id=>device[:id], :to=>false, :time=>time, :type=>'reload', :planned=>true
        device.update :up => false
      end
    end

    def add val
      DB::Event.insert val
    end

  end
end
