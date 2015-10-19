require "sidekiq"
require_relative "../extractors/meta_extractor"
require_relative "../publisher"
require_relative "../utility"

class MetaWorker
  include Sidekiq::Worker
  include Utility

  sidekiq_options :queue => :lc_discovery, :retry => false, :backtrace => true

  def perform(path, label, store)

    begin
      msg = "Extracting lc_discovery #{self.class.name}: #{path} | #{label}"

      logger.info msg
      redis.publish("lc_relay", msg)

      extractor = MetaExtractor.new(project: path, label: label)
      docs = extractor.extract

      Publisher.write("meta", docs, store)

      redis.publish("lc_relay", "...")

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
      redis.publish("lc_relay", e.message)
    end
  end

end
