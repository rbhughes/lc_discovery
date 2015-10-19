# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lc_discovery/version"

Gem::Specification.new do |spec|
  spec.name          = "lc_discovery"
  spec.version       = LcDiscovery::VERSION
  spec.authors       = ["R. Bryan Hughes"]
  spec.email         = ["rbhughes@logicalcat.com"]
  spec.summary       = %q{LMKR GeoGraphix Discovery data crawler}
  spec.description   = %q{omniscience for your interpretation projects}
  spec.homepage      = "http://logicalcat.com"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sequel"
  spec.add_dependency "sqlanywhere"
  spec.add_dependency "nokogiri"
  spec.add_dependency "awesome_print"
  spec.add_dependency "filesize"
  spec.add_dependency "gli"
  spec.add_dependency "sidekiq"
  spec.add_dependency "redis"

  spec.add_dependency "activemodel" , "= 4.2.1"   #compatibility with clowder
  spec.add_dependency "activesupport" , "= 4.2.1" #compatibility with clowder

  #gem "elasticsearch", git: "git://github.com/elasticsearch/elasticsearch-ruby.git"
  #gem "elasticsearch-model", git: "git://github.com/elasticsearch/elasticsearch-rails.git", require: "elasticsearch/model"
  #spec.add_dependency "elasticsearch-persistence"

  #not sure 2015-10-13...
  spec.add_dependency "elasticsearch-model"
  spec.add_dependency "elasticsearch-persistence"



  spec.add_development_dependency "bundler"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "test_construct"

  #spec.add_development_dependency "minitest-filesystem"
  #spec.add_development_dependency "minitest-rg"

end
