module ReassembleTcp

  # packet stream for the same direction and sequence(or acknowledge) number
  class PacketStream
    attr_reader :direction, :seq_ack_num, :range, :pkts

    # @param [Symbol] direction :send or :recv
    # @param [PacketFu::Packet] pkt packet
    def initialize(direction, pkt)
      case direction
      when :send
        @seq_ack_num = pkt.tcp_seq.to_i
      when :recv
        @seq_ack_num = pkt.tcp_ack.to_i
      else
        raise ArgumentError, "direction should be :send or :recv"
      end
      @direction = direction
      @range = pkt.timestamp..pkt.timestamp
      @pkts = [pkt]
    end

    # @param [Symbol] direction :send or :recv
    # @param [PacketFu::Packet] pkt packet
    # @return [Array<PacketFu::Packet>]
    def append(direction, pkt)
      raise ArgumentError unless match?(direction, pkt)
      @pkts << pkt
      @range = Range.new(*[@range.begin, @range.end, pkt.timestamp].minmax)
      @pkts
    end
    alias :<< :append

    # @return [Float] unix time value
    def last_timestamp
      @range.last
    end

    # @param [Symbol] direction :send or :recv
    # @param [PacketFu::Packet] pkt packet
    # @return [Boolean] 
    def match?(direction, pkt)
      num = (direction == :send) ?  pkt.tcp_seq.to_i : pkt.tcp_ack.to_i
      @direction == direction && @seq_ack_num == num
    end

    # reassemble tcp stream data
    # @return [String] reassembled data
    def data
      pkts = @pkts.sort_by!{|pk| pk.timestamp }
      pkts.map{|pkt| pkt.payload }.select{|pay| pay !~ /\A\0+\Z/}.compact.join
    end
  end
end

