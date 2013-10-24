module TMS
  class UDP
    CHANNEL    = '&tdc-lan'
    UDP_SERVER = '194.100.7.227'
    UDP_PORT   = 'bot'.to_i(36)
    CLR = {
      :down => "\0034",
      :up   => "\0039",
      :info => "\00312",
      :rst  => "\003",
    }

    def initialize
      @udp = nil
    end

    def alarm msg
      msg = CHANNEL + ' ' + format_msg(msg)
      open_udp
      @udp.send msg, 0
    end

    def format_msg msg
      msg.sub! /UP:/,   "#{CLR[:up]}UP#{CLR[:rst]}:"
      msg.sub! /DOWN:/, "#{CLR[:down]}DOWN#{CLR[:rst]}:"
      msg
    end

    def open_udp
      if not @udp or @udp.closed?
        @udp = UDPSocket.new
        @udp.connect UDP_SERVER, UDP_PORT
      end
    end

  end
end
