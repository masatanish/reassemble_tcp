require 'spec_helper'

describe ReassembleTcp do
  it 'should have a version number' do
    ReassembleTcp::VERSION.should_not be_nil
  end

  let(:test_pcap_path){ File.expand_path(File.dirname(__FILE__) + '/data/test.pcap') }

  describe '.tcp_connections' do
    subject { ReassembleTcp.tcp_connections(path) }
    context 'with test pcap file' do
      let(:path) { test_pcap_path }
      it { expect(subject).to be_a Array }
      it 'should return 4 connections' do
        expect(subject.size).to eq 4
      end
      it 'should return an array of ReassembleTcp::TcpConnection' do
        expect(subject.first).to be_a ReassembleTcp::TcpConnection
      end
    end
  end

  describe '.tcp_data_stream' do
    pending 'not implemented yet.'
  end
end
