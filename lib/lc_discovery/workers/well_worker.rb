require "sidekiq"
require_relative "../extractors/well_extractor"
require_relative "../publisher"
require_relative "../utility"

class WellWorker
  include Sidekiq::Worker
  include Utility

  sidekiq_options :queue => :lc_discovery, :retry => false, :backtrace => true

  def perform(path, label, store, bulk, mark)

    begin
      msg = "Extracting lc_discovery #{self.class.name}: #{path} | #{label}"

      logger.info msg
      redis.publish("lc_relay", msg)

      extractor = WellExtractor.new(project: path, label: label)
      docs = extractor.extract(bulk, mark)

      Publisher.new.write("well", docs, store)

      redis.publish("lc_relay", "...")

    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace)
      redis.publish("lc_relay", e.message)
    end
  end

end
