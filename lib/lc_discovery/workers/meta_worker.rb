require "sidekiq"
require_relative '../extractors/meta_extractor'
require_relative '../redis_queue'

require "awesome_print"


class MetaWorker
  include Sidekiq::Worker

  def perform(path, label)
    begin
      rq = RedisQueue.redis
      msg = "lc_discovery #{self.class.name}: #{path} -- #{label}"
      logger.info msg
      rq.publish('lc_relay', msg)

      extractor = MetaExtractor.new(project: path, label: label)

      #....................
      # HEY! write to ES here
      #
      ap extractor.extract
      #....................

      rq.publish('lc_relay', '...')

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
      rq.publish('lc_relay', e.message)
    end

  end

end
