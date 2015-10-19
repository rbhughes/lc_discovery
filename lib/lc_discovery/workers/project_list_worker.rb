require "sidekiq"
require_relative "../discovery"
require_relative "../utility"

class ProjectListWorker
  include Sidekiq::Worker
  include Utility

  EXPIRY = 60

  def perform(root="c:/programdata/geographix/projects", deep_scan=false)

    raise ArgumentError, "root cannot be nil" if root.nil?

    logger.info("processing qid: #{qid}")

    puts "ProjectListWorker called for #{root}"

    begin

      redis.set(qid, "working")
      redis.publish("lc_relay", "working on #{qid}")
      

      if File.exists?(root)
        projects = Discovery.project_list(root, deep_scan)

        if projects.empty?
          redis.rpush("#{qid}_payload", "No projects in: #{root}")
          redis.set(qid, "fail")
        else
          projects.each do |proj|
            redis.rpush("#{qid}_payload", proj)
          end
          redis.set(qid, "done")
        end

      else
        redis.rpush("#{qid}_payload", "Cannot resolve path: #{root}")
        redis.set(qid, "fail")
      end

    rescue Exception => e
      puts "!"*40
      puts e
      puts "!"*40
      redis.rpush("#{qid}_payload", e.backtrace.inspect)
      redis.set(qid, "fail")
    ensure
      redis.expire("#{qid}_payload", EXPIRY)
      redis.expire(qid, EXPIRY)
    end

  end

  private

  def qid
    @qid ||= ["lc_discovery", self.class.name, self.jid].join("_").downcase
  end

end

