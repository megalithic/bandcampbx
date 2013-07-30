# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bandcampbx/version'

Gem::Specification.new do |spec|
  spec.name          = "bandcampbx"
  spec.version       = BandCampBX::VERSION
  spec.authors       = ["Seth Messer"]
  spec.email         = ["seth.messer@gmail.com"]
  spec.description   = %q{This is a client library for the CampBX API that supports instantiating multiple clients in the same process.}
  spec.summary       = %q{Outstanding CampBX library.}
  spec.homepage      = "http://github.com/megalithic/bandcampbx"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'net-http-persistent'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'json_pure'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", '2.14.0.rc1'
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "pry"
end
