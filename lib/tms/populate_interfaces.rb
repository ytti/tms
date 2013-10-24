module TMS

  class PopulateInterfaces
    UP   = 1
    DOWN = 2
    
    def initialize event_handler
      @eh = event_handler
    end
   
    def run
      update_db get_ints
    end
   
    private

    def devices
      DB::Device.map :ip
    end
    
    def get_ints
      dev = Hash.new { |h,k| h[k] = [] }
      devices.each do |device|
        ifdescr     = SNMP.new(device).ifdescr
        ifalias     = SNMP.new(device).ifalias
        operstatus  = SNMP.new(device).operstatus
        operstatus.each do |index, status|
          _, name = ifdescr.assoc index
          _, desc = ifalias.assoc index
          up = status == UP ? true : false
          dev[device] << { :index => index, :name => name, :up => up, :description => desc }
        end
      end
      dev
    end
    
    def update_db devices
      devices.each do |device, ints|
        dev_id = DB::Device.where(:ip=>device).get :id
        ints.each do |int|
          entry = DB::Interface.first :device_id=>dev_id, :name=>int[:name]
          if entry
            update_entry entry, int, DB::Device[dev_id][:ip]
          else
            time = Time.now.utc
            DB::Interface.insert :device_id=>dev_id, :index=>int[:index], :name=>int[:name],
                                 :up=>int[:up], :description=>int[:description], :seen_first=>time, :seen_last=>time
          end
        end
      end
    end
    
    def update_entry db, poll, ip
       if (db[:up] != poll[:up]) and poll[:description].to_s[0..3] != 'EDGE'
         @eh << { :type=>:linkchange, :up=>poll[:up], :index=>poll[:index], :name=>poll[:name], :source=>ip, :time=>Time.now.utc }
       end
       db.update :index=>poll[:index], :description=>poll[:description], :seen_last=>Time.now.utc
    end

  end
end
