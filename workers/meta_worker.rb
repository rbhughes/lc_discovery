require "sidekiq"
#require "filesize"
#require "nokogiri"
#require "date"

#require_relative "../lib/lc_discovery/sybase"
#require_relative "../lib/lc_discovery/discovery"
require_relative '../lib/lc_discovery/ex_meta'


require_relative '../lib/lc_discovery/redis_queue'

require "awesome_print"


class MetaWorker
  include Sidekiq::Worker

  def perform(path, label)
    begin
      rq = RedisQueue.redis
      msg = "lc_discovery #{self.class.name}: #{path} -- #{label}"
      logger.info msg
      rq.publish('lc_relay', msg)

      require 'awesome_print'
      extractor = ExMeta.new(project: path, label: label)

      #m = ExMeta::Meta.new
      #ap m

      ap extractor.extract

      rq.publish('lc_relay', '...')

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
      rq.publish('lc_relay', e.message)
    end

  end


end


