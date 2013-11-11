require 'packetfu'

# extension for PacketFu
module PacketFu
  class Timestamp
    def to_f
      sec.to_i + (usec.to_i / 1000_000.0)
    end
  end

  class PcapFile
    def self.read_packets_with_timestamp(fname, &block)
      count = 0
      packets = [] unless block
      read(fname) do |packet| 
        pkt = Packet.parse(packet.data.to_s)
        pkt.timestamp = packet.timestamp.to_f
        if block
          count += 1
          yield pkt
        else
          packets << pkt
        end
      end
      block ? count : packets
    end
  end

  class Packet
    # @return [Fixnum] timestamp unix time
    attr_accessor :timestamp
  end
end
