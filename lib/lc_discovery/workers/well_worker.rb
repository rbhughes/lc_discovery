require "sidekiq"
require_relative "../extractors/well_extractor"
require_relative "../publisher"

class WellWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :lc_discovery, :retry => false, :backtrace => true

  def perform(path, label, store, bulk, mark)

    begin
      msg = "Extracting lc_discovery #{self.class.name}: #{path} | #{label}"

      logger.info msg
      ###RedisQueue.redis.publish("lc_relay", msg)

      #docs = WellExtractor.new(project: path, label: label).extract(bulk, mark)

      extractor = WellExtractor.new(project: path, label: label)
      docs = extractor.extract(bulk, mark)


      Publisher.write("well", docs, store)

      ###RedisQueue.redis.publish("lc_relay", "...")

    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace)
      ###RedisQueue.redis.publish("lc_relay", e.message)
    end
  end

end
