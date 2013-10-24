module TMS

  class SNMP
    require 'snmp'

    OID = {
      :ifDescr    => '1.3.6.1.2.1.2.2.1.2',
      :operStatus => '1.3.6.1.2.1.2.2.1.8',
      :ifAlias    => '1.3.6.1.2.1.31.1.1.1.18',
    }
    BULK_MAX = 50

    def initialize host, community=CFG.community
      @snmp = ::SNMP::Manager.new :Host => host, :Community => community,
                                  :Timeout => 0.5, :Retries => 3, :MibModules => []
    end

    def bulkwalk root
      last, oid, vbs = false, root, []
      while not last
        r = @snmp.get_bulk 0, BULK_MAX, oid
        r.varbind_list.each do |vb|
          oid = vb.name.to_str
          (last = true; break) if not oid.match /^#{Regexp.quote root}/
          vbs.push vb
        end
      end
      vbs
    end

    def ifdescr
      get :ifDescr
    end

    def operstatus
      get :operStatus
    end

    def ifalias
      get :ifAlias
    end

    private
     
    def get oid
      begin
        bulkwalk(OID[oid]).map do |vb|
          [vb.oid.last, vb.value]
        end
      rescue ::SNMP::RequestTimeout
        []
      end
    end
  end
end

module SNMP
  class VarBindList
    def name oid
      vb = detect { |vb| vb.name.join('.').match oid }
      vb.value if vb
    end
  end
end
