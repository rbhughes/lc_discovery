require "sidekiq"

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'logicalcat', :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'logicalcat' }
end

#require_relative 'meta'
require_relative 'project_list_worker'
