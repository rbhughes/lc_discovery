require "sidekiq"
require_relative '../lib/lc_discovery/discovery'
require_relative '../lib/lc_discovery/redis_queue'

class ProjectListWorker
  include Sidekiq::Worker
  EXPIRY = 60

  def perform(root='c:/programdata/geographix/projects', deep_scan=false)
    logger.info "processing qid: #{qid}"
    puts "#{Time.now}  processing qid: #{qid}"

    begin
      
      rq = RedisQueue.redis
      rq.set qid, 'working'

      #rq.rpush "#{qid}_payload", "NOT EXIST?: #{root}" unless File.exists?(root)

      #projects = Discovery.project_list(root, deep_scan)
      #rq.rpush "#{qid}_payload", "NO PROJECTS IN: #{root}" if projects.empty?
      
      #projects.each do |proj|
      #  rq.rpush "#{qid}_payload", proj
      #end

      if File.exists?(root)
        projects = Discovery.project_list(root, deep_scan)

        if projects.empty?
          rq.rpush "#{qid}_payload", "No projects found in: #{root}"
          rq.set qid, 'fail'
        else
          projects.each { |proj| rq.rpush "#{qid}_payload", proj }
          rq.set qid, 'done'
        end

      else
        rq.rpush "#{qid}_payload", "Worker cannot resolve path: #{root}"
        rq.set qid, 'fail'
      end


    rescue Exception => e
      rq.rpush "#{qid}_payload", e.backtrace.inspect
      rq.set qid, 'fail'
    ensure
      rq.expire "#{qid}_payload", EXPIRY
      rq.expire qid, EXPIRY
    end

  end

  private

  def qid
    @qid ||= ['lc_discovery', self.class.name, self.jid].join('_').downcase
  end

end

