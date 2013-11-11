# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reassemble_tcp/version'

Gem::Specification.new do |spec|
  spec.name          = "reassemble_tcp"
  spec.version       = ReassembleTcp::VERSION
  spec.authors       = ["masatanish"]
  spec.email         = ["masatanish@gmail.com"]
  spec.description   = %q{Reassemble TCP fragment data from pcap file like Wireshark.}
  spec.summary       = %q{Reassemble TCP fragment data from pcap file like Wireshark.}
  spec.homepage      = "https://github.com/masatanish/reassemble_tcp"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "packetfu", "~> 1.1.9"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
