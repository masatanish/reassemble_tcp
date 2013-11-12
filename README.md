# ReassembleTcp

Ruby gem for reassembling TCP fragment data from pcap file like Wireshark.

See: http://wiki.wireshark.org/TCP_Reassembly

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reassemble_tcp'
```

And then execute:


    $ bundle

Or install it yourself as:

    $ gem install reassemble_tcp

## Usage

```ruby
require 'reassemble_tcp'

ReassembleTcp.tcp_data_stream('some.pcap') {|t, from, to, data|
  puts "[#{t.strftime("%Y/%m/%d %H:%M:%S.%6N")} #{from} -> #{to}"
  puts data[0..100]
  puts
}
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
