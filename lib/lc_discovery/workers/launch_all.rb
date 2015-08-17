require "sidekiq"

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'logicalcat', :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'logicalcat' }
end

require_relative 'project_list_worker'
require_relative 'extract_dispatch_worker'
require_relative 'meta_worker'
require_relative 'well_worker'
