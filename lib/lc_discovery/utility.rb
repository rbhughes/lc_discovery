require_relative "./lc_env.rb"
require_relative "./discovery.rb"
require "digest/sha1"
require "net/http"
require "time"
require "redis-objects"
require "connection_pool"

require "awesome_print"


module Utility

  REDIS_EXPIRY = (5 * 60) # lifetime of redis-objects

  ###
  # (instance method gets picked up Publisher's include)
  def redis
    @redis ||= Redis.new url: LcEnv.redis_url
  end



  module_function



  ###
  #
  def redis_pool
    @redis_pool ||= 
      Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
      Redis.new url: LcEnv.redis_url
    }
  end

  ###
  # Every doc gets this for provenance 
  def base_doc(proj, label)
    proj_host = Discovery.parse_host(proj)
    norm_path =
      proj.gsub(/\\|\/|:/, "_").chomp.strip.squeeze("_").gsub(/^_|_$/,"")

    {
      label: label,
      project_id: "#{label}:#{proj_host}:#{norm_path}".downcase,
      project_path: proj,
      project_name: File.basename(proj),
      project_home: Discovery.parse_home(proj),
      project_host: proj_host
    }
  end

  ###
  # Because backslashes are...irritating
  def fwd_slasher(s)
    s.strip.gsub("\\", "/") rescue nil
  end


  ###
  # Accepts time as int (like File.stat uses) and converst to utc.iso8601
  def self.to_iso_date(i)
    Time.at(i).utc.iso8601
  end

  ###
  #
  def lowercase_symbol_keys(h)
    Hash[h.map {|k, v| [k.to_s.downcase.gsub(/\s/,"_").to_sym, v] }]
  end



  #----------
  # TODO: add a rescue for unknown model?
  def invoke_model(type)
    model_path = File.join(File.dirname(__FILE__),"models/#{type}.rb")
    require model_path
    type.to_s.split("_").collect(&:capitalize).join.constantize
  end


  # Mirrors the enqueue behavior of Clowder's Utility.enqueue_extracts(home)
  def cli_extract(extract, path, label, store)

    begin

      require File.join(File.dirname(__FILE__),
                      "workers/#{extract.downcase}_worker.rb")

      require File.join(File.dirname(__FILE__),
                      "extractors/#{extract.downcase}_extractor.rb")

      extractor = "#{extract.capitalize}Extractor".constantize
      worker = "#{extract.capitalize}Worker".constantize
      bulk = extractor::BULK || 1
      publisher = Publisher.new

      if extractor.respond_to?(:parcels)

        extractor.parcels(path).each do |job|
          docs = extractor.new(
            project: path,
            label: label
          ).extract(job[:bulk], job[:mark])
          publisher.write(extract.downcase, docs, store)
        end

      else
        docs = extractor.new(project: path, label: label).extract
        publisher.write(extract.downcase, docs, store)
      end

    rescue Exception => e
      puts e
    end
  end




end

