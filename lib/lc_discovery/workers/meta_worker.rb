require "sidekiq"
require_relative "../extractors/meta_extractor"
require_relative "../redis_queue"
require_relative "../publisher"

class MetaWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :lc_discovery, :retry => false, :backtrace => true

  def perform(path, label, store)

    begin
      msg = "Extracting lc_discovery #{self.class.name}: #{path} | #{label}"

      logger.info msg
      RedisQueue.redis.publish("lc_relay", msg)

      doc = MetaExtractor.new(project: path, label: label).extract

      Publisher.write("meta", [doc], store)

      RedisQueue.redis.publish("lc_relay", "...")

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
      RedisQueue.redis.publish("lc_relay", e.message)
    end
  end

end
