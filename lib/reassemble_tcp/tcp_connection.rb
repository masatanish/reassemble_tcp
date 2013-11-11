require 'packetfu'

module ReassembleTcp

  # TCP connection object
  class TcpConnection
    attr_reader :syn, :timestamp_range

    # @param [PacketFu::TCPPacket] pkt SYN packet
    def initialize(pkt)
      raise ArgumentError, "#{pkt} is not PacketFu::TCPPacket." unless pkt.kind_of? PacketFu::TCPPacket
      raise ArgumentError, "#{pkt} is not TCP packet." unless pkt.is_tcp?
      raise ArgumentError, "#{pkt} is not SYN packet." unless pkt.tcp_flags[:syn] == 1

      @syn = pkt
      @timestamp_range = (@syn.timestamp .. Float::INFINITY)
      @stream_array = []
    end

    def send?(pkt)
      ((@syn.tcp_dport == pkt.tcp_dport and @syn.ip_dst == pkt.ip_dst) and
       (@syn.tcp_sport == pkt.tcp_sport and @syn.ip_src == pkt.ip_src))
    end

    def recv?(pkt)
      ((@syn.tcp_sport == pkt.tcp_dport and @syn.ip_src == pkt.ip_dst) and
       (@syn.tcp_dport == pkt.tcp_sport and @syn.ip_dst == pkt.ip_src))
    end

    def src_ip
      @syn.ip_src_readable
    end

    def src_port
      @syn.tcp_sport
    end

    def dst_ip
      @syn.ip_dst_readable
    end

    def dst_port
      @syn.tcp_dport
    end

    def direction(pkt)
      raise ArgumentError, "#{pkt} is not matched with this connection" unless match?(pkt)
      return :send if send?(pkt)
      return :recv if recv?(pkt)
      raise "error"
    end

    def match?(pkt)
      raise ArgumentError, "#{pkt} is not TCP packet." unless pkt.is_tcp?
      # target packet is the same source and destination
      return false unless (send?(pkt) || recv?(pkt))
      # target packet is in connection's time range
      return @timestamp_range.include? pkt.timestamp
    end

    def append(pkt)
      raise ArgumentError, "#{pkt} is not matched with this connection" unless match?(pkt)
      if pkt.tcp_flags[:fin] == 1 || pkt.tcp_flags[:rst] == 1
        # FIN or RST packet is treated as end of the TCP stream.
        # and it determines time range of the TCP stream.
        # FIN packet is not included int Streams
        @timestamp_range = (@syn.timestamp .. pkt.timestamp)
        return
      end
      dir = direction(pkt)
      # store packets into packet stream
      pkt_stm = @stream_array.find{|stm| stm.match? dir, pkt }
      if pkt_stm.nil?
        @stream_array << PacketStream.new(dir, pkt)
      else
        pkt_stm.append(dir, pkt)
      end
    end
    alias :<< :append

    # @yieldparam [Range] time time range of stream data
    # @yieldparam [Symbol] direction :send or :recv
    # @yieldparam [String] data reassembled TCP data
    def tcpdata(&block)
      arr = []
      @stream_array.sort_by{|pstm| pstm.last_timestamp }.each do |s|
        next if s.data.nil? || s.data.empty?
        if block.nil?
          arr << [s.range, s.direction, s.data]
        else
          yield s.range, s.direction, s.data
        end
      end
      return arr
    end
  end
end

