module TMS
  class Periodic
    EXPIRY = 60*60*24*7
    require 'tms/populate_devices'
    require 'tms/populate_interfaces'

    def initialize event_handler, periodic=true
      @dev     = PopulateDevices.new event_handler
      @int     = PopulateInterfaces.new event_handler
      main_loop if periodic
    end

    def run
      @dev.run
      @int.run
      prune_db
    end

    private

    def prune_db
      expiry =  (Time.now - EXPIRY).to_i
      expiry = Sequel.function(:datetime, expiry, 'unixepoch') # FIXME: this is SQLite specific?
      dev_delete = []
      int_delete = []
      DB::Device.where{seen_last < expiry}.each do |row|
        dev_delete << row
      end
      dev_delete.each do |dev_id|
        DB::Interface.where(:device_id => dev_id).each do |row|
          int_delete << row
        end
      end
      DB::Interface.where{seen_last < expiry}.each do |row|
        int_delete << row
      end
      int_delete.uniq.each do |int|
        DB::Event.where(:interface_id => int[:id]).each do |row|
          Log.warn 'deleting interface: ' + int[:name] + ' from events'
          row.delete
        end
        Log.warn 'deleting interface: ' + int[:name] + ' from device: ' + DB::Device[int[:device_id]][:name]
	int.delete
      end
      dev_delete.uniq.each do |dev|
        DB::Event.where(:device_id => dev[:id]).each do |row|
          Log.warn 'deleting device: ' + dev[:name] + ' from events'
          row.delete
        end
        Log.warn 'deleteting device: ' + edv[:name] + ' [' + dev[:id] + ']'
        dev.delete
      end
    end

    def main_loop
      loop do
        run
        sleep CFG.periodic.to_i*60
      end
    end

    private

  end
end
