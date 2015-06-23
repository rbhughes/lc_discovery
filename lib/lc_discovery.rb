require 'lc_discovery/version'
require 'lc_discovery/discovery'
require 'lc_discovery/extracts'
#require 'lc_discovery/stats'
require 'lc_discovery/sybase'
require 'lc_discovery/utility'
#require 'sidekiq'


#module LcDiscovery

require 'redis'
@redis = Redis.new(:host => '127.0.0.1', :port => 6379)

#end
