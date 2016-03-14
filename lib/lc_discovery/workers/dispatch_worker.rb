require "sidekiq"
require "awesome_print"
require_relative "../discovery"
require_relative "../utility"

class DispatchWorker
  include Sidekiq::Worker
  include Utility

  sidekiq_options :queue => :lc_discovery, :retry => false, :backtrace => true

  def perform(extract, path, label, store)
    begin
      msg = "lc_discovery #{extract} | #{path} | #{label} | #{store}"

      redis.publish("lc_relay", msg)
      puts msg #TODO: MERGE THIS INTO LOGGER!

      case extract
      when "PROJECT"
        ProjectWorker.perform_async(path, label, store)
      when "WELL"
        WellExtractor.parcels(path).each do |job|
          WellWorker.perform_async(path, label, store, job[:bulk], job[:mark])
        end
      when "TEST"
        TestWorker.perform_async #mocked, so don't do anything
      else
        logger.error("unknown extract type: #{extract}")
      end

      redis.publish("lc_relay", "...")
      "dispatched" # a truthy return

    rescue Exception => e
      puts "^"*40
      puts e
      puts "!"*40
      logger.error e.message
      logger.error e.backtrace
      redis.publish("lc_relay", e.message)
      return false
    end
  end

end
