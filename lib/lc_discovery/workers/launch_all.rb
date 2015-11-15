require "sidekiq"
require "awesome_print"

Sidekiq.configure_client do |config|
  ap config
  config.redis = { :namespace => "logicalcat", :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => "logicalcat" }
end

require_relative "project_list_worker"
require_relative "dispatch_worker"
require_relative "project_worker"
require_relative "well_worker"
