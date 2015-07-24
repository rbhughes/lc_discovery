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
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }


  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'sequel' #, '~> 4.18'
  spec.add_dependency 'sqlanywhere' #, '~> 0.1'
  spec.add_dependency 'nokogiri' #, '~> 1.6'
  spec.add_dependency 'awesome_print' #, '~> 1.6'
  spec.add_dependency 'filesize' #, '~> 0.0'
  spec.add_dependency 'gli' #, '~> 2.12'
  spec.add_dependency 'sidekiq' #, '~> 3.3'
  spec.add_dependency 'redis' #, '~> 3.2'

  #gem 'elasticsearch', git: 'git://github.com/elasticsearch/elasticsearch-ruby.git'
  #gem 'elasticsearch-model', git: 'git://github.com/elasticsearch/elasticsearch-rails.git', require: 'elasticsearch/model'
  spec.add_dependency 'elasticsearch-persistence'



  spec.add_development_dependency 'bundler' #, '~> 1.7'
  spec.add_development_dependency 'rake' #, '~> 10.0'

    
end
