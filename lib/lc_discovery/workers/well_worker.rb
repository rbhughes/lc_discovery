require "sidekiq"
require_relative "../redis_queue"
require_relative "../models/well"
require_relative "../extractors/well_extractor"

class WellWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :lc_discovery, :retry => false, :backtrace => true


  def perform(path, label, store, bulk, mark)

    begin
      rq = RedisQueue.redis
      msg = "lc_discovery #{self.class.name}: #{path} | #{label} | #{store} | \
      #{bulk} | #{mark}"

      logger.info msg

      rq.publish("lc_relay", msg)

      #extractor = WellExtractor.new(project: path, label: label)
      #docs = extractor.extract(bulk, mark)

      docs = WellExtractor.new(project: path, label: label).extract(bulk, mark)

      if store == "elasticsearch"
        docs.each{ |doc| Well.create(doc) }
      else
        puts "WOULD BE PUBLISHING #{docs.size} DOCS to #{store}"
        ap docs
      end

      rq.publish("lc_relay", "...")

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
      rq.publish("lc_relay", e.message)
    end
  end

end
