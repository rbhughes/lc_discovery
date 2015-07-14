require "sidekiq"
require "awesome_print"

require_relative '../lib/lc_discovery/redis_queue'



class MetaWorker
  include Sidekiq::Worker
  EXPIRY = 60

  def perform(path, label)
    puts '-'*30
    puts "path ---- #{path}"
    puts "label --- #{label}"
    logger.info "processing meta_worker"
    puts "#{Time.now}  processing METAWORKER"
  end

end
