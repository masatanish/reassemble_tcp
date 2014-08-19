require 'reassemble_tcp/version'
require 'reassemble_tcp/version'
require 'reassemble_tcp/packetfu_extend'
require 'reassemble_tcp/packet_stream'
require 'reassemble_tcp/tcp_connection'

module ReassembleTcp

  # get TCP connections from pcap file
  # @param [String] filepath pcapfile path
  # @return [Array<ReassembleTcp::TcpConnection>] tcp connections
  def self.tcp_connections(filepath)
    streams = []
    PacketFu::PcapFile.read_packets_with_timestamp(filepath) {|pkt|
      next unless pkt.is_ip? and pkt.is_tcp?
      stm = streams.find{|ts| ts.match?(pkt) }
      if pkt.tcp_flags[:syn] == 1 && pkt.tcp_flags[:ack] == 0
        next unless stm.nil?
        streams << TcpConnection.new(pkt)
      else
        next if stm.nil?
        stm << pkt
      end
    }
    streams
  end

  # get reassembled tcp data
  # @param [String] filepath pcapfile path
  # @yield [time, from, to, data]
  # @yieldparam [Time] time packet timestamp
  # @yieldparam [String] from source IP address
  # @yieldparam [String] to destination IP address
  # @yieldparam [String] data tcp resassembled data
  def self.tcp_data_stream(filepath, &block)
    stream_data = {}
    ReassembleTcp.tcp_connections(filepath).each do |conn|
      dst = conn.dst_ip
      src = conn.src_ip
      conn.tcpdata do |range, dir, data|
        next if data.nil? || data.empty?
        from, to = (dir == :send ) ? [src, dst] : [dst, src]
        etime = Time.at(range.last)
        stream_data[etime] = [from, to, data]
      end
    end
    stream_data.keys.sort.each do |etime|
      from, to, data = stream_data[etime]
      yield etime, from, to, data
    end
    nil
  end
end
