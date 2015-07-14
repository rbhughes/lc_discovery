require "sidekiq"
require "awesome_print"

require_relative '../lib/lc_discovery/redis_queue'



class MetaWorker
  include Sidekiq::Worker
  EXPIRY = 60

  def perform(opts)
    puts '-'*30
    puts opts
    logger.info "processing meta_worker"
    puts "#{Time.now}  processing METAWORKER"
  end

end
