require "sidekiq"

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'logicalcat', :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'logicalcat' }
end

#require_relative 'project_list_worker'
#require_relative 'extract_dispatch_worker'

require_relative './lib/lc_discovery/workers/meta_worker'



path = 'c:/programdata/geographix/projects/stratton'
label = 'blue'
store = 'elasticsearch'

MetaWorker.perform_async(path, label, store)


