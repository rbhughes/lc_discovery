require "sidekiq"
require_relative "../discovery"
require_relative "../redis_queue"

class ProjectListWorker
  include Sidekiq::Worker
  EXPIRY = 60

  def perform(root="c:/programdata/geographix/projects", deep_scan=false)
    logger.info("processing qid: #{qid}") #TODO: standardize worker loggers

    begin

      RedisQueue.redis.set(qid, "working")
      RedisQueue.redis.publish("lc_relay", "working on #{qid}")

      if File.exists?(root)
        projects = Discovery.project_list(root, deep_scan)

        if projects.empty?
          RedisQueue.redis.rpush("#{qid}_payload", "No projects in: #{root}")
          RedisQueue.redis.set(qid, "fail")
        else
          projects.each do |proj|
            RedisQueue.redis.rpush("#{qid}_payload", proj)
          end
          RedisQueue.redis.set(qid, "done")
        end

      else
        RedisQueue.redis.rpush("#{qid}_payload", "Cannot resolve path: #{root}")
        RedisQueue.redis.set(qid, "fail")
      end

    rescue Exception => e
      RedisQueue.redis.rpush("#{qid}_payload", e.backtrace.inspect)
      RedisQueue.redis.set(qid, "fail")
    ensure
      RedisQueue.redis.expire("#{qid}_payload", EXPIRY)
      RedisQueue.redis.expire(qid, EXPIRY)
    end

  end

  private

  def qid
    @qid ||= ["lc_discovery", self.class.name, self.jid].join("_").downcase
  end

end

