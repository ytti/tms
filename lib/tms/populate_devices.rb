module TMS
  class PopulateDevices

    def initialize event_handler=nil
      @eh = event_handler
    end
   
    def run
      save_tms load_corona
    end

    private 

    def load_corona
      devs = []
      db = Sequel.sqlite CFG.corona
      db[:device].each do |row|
        devs << { :name=>row[:ptr], :ip=>row[:ip] }
      end
      db.disconnect
      devs
    end
    
    def save_tms devs
      devs.each do |dev|
        time = Time.now.utc
        if row = DB::Device.first(:ip => dev[:ip])
          row.update :seen_last=>time
        else
          DB::Device.insert :name=>dev[:name], :ip=>dev[:ip], :up=>false, :seen_first=>time, :seen_last=>time
        end
      end
    end

  end
end
