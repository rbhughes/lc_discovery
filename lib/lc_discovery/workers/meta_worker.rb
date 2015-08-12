require "sidekiq"
require_relative '../redis_queue'
require_relative '../models/meta'
require_relative '../extractors/meta_extractor'

class MetaWorker
  include Sidekiq::Worker

  def perform(path, label)
    begin
      rq = RedisQueue.redis
      msg = "lc_discovery #{self.class.name}: #{path} -- #{label}"
      logger.info msg
      rq.publish('lc_relay', msg)

      MetaExtractor.new(project: path, label: label).extract.each do |x|
        Meta.create(x) 
      end

      rq.publish('lc_relay', '...')

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
      rq.publish('lc_relay', e.message)
    end
  end

end
