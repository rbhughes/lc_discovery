require 'sidekiq'
require 'awesome_print'
require_relative '../discovery'
require_relative '../redis_queue'

class ExtractDispatchWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :lc_discovery, :retry => false, :backtrace => true

  def perform(extract, path, label, store)
    begin
      rq = RedisQueue.redis
      msg = "lc_discovery #{extract}: #{path} | #{label} | #{store}"
      logger.info msg

      rq.publish('lc_relay', msg)

      if extract == 'meta'

        MetaWorker.perform_async(path, label, store)

      elsif extract == 'well'

        WellExtractor.parcels(path).each do |job|
          WellWorker.perform_async(path, label, store, job[:bulk], job[:mark])
        end

      end

      rq.publish('lc_relay', '...')

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
      rq.publish('lc_relay', e.message)
    end
  end

end
