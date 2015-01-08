# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lc_discovery/version'

Gem::Specification.new do |spec|
  spec.name          = "lc_discovery"
  spec.version       = LcDiscovery::VERSION
  spec.authors       = ["R. Bryan Hughes"]
  spec.email         = ["rbhughes@logicalcat.com"]
  spec.summary       = %q{LMKR GeoGraphix Discovery stats, search and PPDM}
  spec.description   = %q{omniscience for your interpretation projects}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
    
end
