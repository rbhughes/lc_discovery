require "sidekiq"
require_relative "../redis_queue"
require_relative "../models/meta"
require_relative "../extractors/meta_extractor"

class MetaWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :lc_discovery, :retry => false, :backtrace => true





  def perform(path, label, store)
    begin
      rq = RedisQueue.redis
      msg = "lc_discovery #{self.class.name}: #{path} | #{label} | #{store}"
      logger.info msg

      rq.publish("lc_relay", msg)

      ###
      #Sidekiq.redis { |c| logger.info "redis location: [#{c.client.location }]" }
      #redis_info = Sidekiq.redis { |conn| conn.info }
      #logger.info "connected clients: [#{redis_info["connected_clients"]}]"
      ###
      #Sidekiq.redis { |c| puts "redis location: [#{c.client.location }]" }
      #redis_info = Sidekiq.redis { |conn| puts conn.info }
      #puts "connected clients: [#{redis_info["connected_clients"]}]"

      extracts = MetaExtractor.new(project: path, label: label).extract


      #extracts.each do |x|
      #  Meta.create(x) 
      #end

      rq.publish("lc_relay", "...")

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
      rq.publish("lc_relay", e.message)
    end
  end

end
