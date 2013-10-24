module TMS
  class Trap

    OID = {
      :linkDown => '1.3.6.1.6.3.1.1.5.3',
      :linkUp => '1.3.6.1.6.3.1.1.5.4',
      :reload => '1.3.6.1.4.1.9.0.0',
      :ciscoConfigManEvent => '1.3.6.1.4.1.9.9.43.2.0.1',
      :authenticationFailure => '1.3.6.1.6.3.1.1.5.5',
      :ifIndex => '1.3.6.1.2.1.2.2.1.1',
      :ifDescr => '1.3.6.1.2.1.2.2.1.2',
      :entConfigChange => '1.3.6.1.2.1.47.2.0.1',
      :coldStart => '1.3.6.1.6.3.1.1.5.1',
    }

    private 

    def initialize event
      @event = event
      ::SNMP::TrapListener.new(:Host=>CFG.trap['address'], :Port=>CFG.trap['port']) do |snmp|
        snmp.on_trap_default { |trap| process_trap trap }
      end
    end

    def process_trap trap
      case trap.trap_oid.join('.')
      when OID[:linkDown]
        process_linkchange trap, false
      when OID[:linkUp]
        process_linkchange trap, true
      when OID[:reload]
        @event << { :type=>:reload, :source=>trap.source_ip, :time=>Time.now.utc }
      when *OID.values
        # We know it, but we don't care about it'
      else
        # unknown, write it for analysis
        open(CFG.trap['file'], 'a') do |file|
          file.puts Time.now
          file.puts trap.trap_oid.join('.')
          PP.pp trap, file
          file.puts
        end
      end
    end

    def process_linkchange trap, up
      index  = trap.vb_list.name OID[:ifIndex]
      name   = trap.vb_list.name OID[:ifDescr]
      source = trap.source_ip
      @event << { :type=>:linkchange, :up=>up, :index=>index, :name=>name, :source=>source, :time=>Time.now.utc }
    end

  end
end
