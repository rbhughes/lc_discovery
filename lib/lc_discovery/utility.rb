require_relative "./lc_env.rb"
require "digest/sha1"
require "net/http"
require "redis"



module Utility

  #---------- 
  # (instance method gets picked up Publisher's include)
  def redis
    @redis ||= Redis.new url: LcEnv.redis_url
  end


  module_function

  #----------
  def base_doc(proj, label)
    {
      label: label,
      project_id: lc_id("#{proj} #{label}"),
      project_path: proj,
      project_name: File.basename(proj),
      project_home: Discovery.parse_home(proj),
      project_host: Discovery.parse_host(proj)
    }
  end

  #----------
  # Because backslashes are...irritating
  def fwd_slasher(s)
    s.strip.gsub("\\", "/") rescue nil
  end

  #----------
  # Make a sort of guid, which in some cases is a natural key
  def lc_id(s)
    Digest::SHA1.hexdigest(fwd_slasher(s.downcase))
  end

  #----------
  def camelized_class(str)
    str.to_s.split("_").map {|w| w.capitalize}.join.constantize
  end

  #----------
  def lowercase_symbol_keys(h)
    Hash[h.map {|k, v| [k.to_s.downcase.gsub(/\s/,"_").to_sym, v] }]
  end

  #----------
  # TODO: add a rescue for unknown model?
  def invoke_lc_model(type)
    model_path = File.join(File.dirname(__FILE__),"models/#{type}.rb")
    require model_path
    model = type.to_s.split("_").collect(&:capitalize).join.constantize
  end

  #----------
  # usage
  # irb -r "./lib/lc_discovery/utility.rb"
  # Utility.init_elasticsearch_index(:well)
  # (it will try to find a model in lib/models)
  #
  #TODO: define where logger needs to happen
  #client.transport.logger.formatter = proc { |s, d, p, m| "\e[2m# #{m}\n\e[0m" }
  def init_elasticsearch_index(type)
    begin

      model = invoke_lc_model(type)

      model.gateway.client.indices.delete index: model.index_name rescue nil
      model.gateway.client.indices.create index: model.index_name, body: {
        settings: model.settings.to_hash, 
        mappings: model.mappings.to_hash
      }

      puts "Initialized #{model.index_name} index"
      true
    #rescue Elasticsearch::Transport::Transport::Errors::NotFound
    rescue Exception => e
      puts e.message
      puts e.backtrace
      return false
    end
  end


  #----------
  def drop_elasticsearch_index(type)
    begin
      model = invoke_lc_model(type)
      model.gateway.client.indices.delete index: model.index_name #rescue nil
      true
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => nf
      puts "No index found to delete."
      false
    rescue Exception => e
      puts e.class
      puts e.message
      puts e.backtrace
      return false
    end
  end

  #----------
  def elasticsearch_index_present?(type)
    uri = URI("#{LcEnv.elasticsearch_url}/_cat/indices")
    all = Net::HTTP.get(uri).split("\n").map{|x| x.split[2]}
    all.any?{ |s| s.casecmp(type.to_s)==0 } ? true : false
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
      bulk = extractor::BULK


      puts "*"*40
      puts "extract=#{extract}  path=#{path}   label=#{label}   store=#{store}"
      puts "*"*40


      if extractor.respond_to?(:parcels)

        extractor.parcels(path).each do |job|
          docs = extractor.new(
            project: path,
            label: label
          ).extract(job[:bulk], job[:mark])
          #Publisher.write(extract.downcase, docs, store)


        end

      else
        docs = extractor.new(project: path, label: label).extract
        #Publisher.write(extract.downcase, docs, store)
      end

    rescue Exception => e
      puts e
    end
  end



  # The string identifying a remote worker's semaphore
  #def qid(args)
  #  "#{args['queue']}_#{args['worker']}_#{args['jid']}".gsub(/\s/,'').downcase
  #end
  

end

