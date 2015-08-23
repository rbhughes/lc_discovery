require "digest/sha1"

# require all the elasticsearch models
#model_path = File.join(File.dirname(__FILE__),"models/*.rb")
#Dir[model_path].each { |file| require file }



module Utility

  module_function

  # Because backslashes are...irritating
  def fwd_slasher(s)
    s.strip.gsub("\\", "/") rescue nil
  end

  # Make a sort of guid, which in some cases is a natural key
  def lc_id(s)
    Digest::SHA1.hexdigest(fwd_slasher(s.downcase))
  end


  def camelized_class(str)
    str.to_s.split("_").map {|w| w.capitalize}.join.constantize
  end

  def lowercase_symbol_keys(h)
    Hash[h.map {|k, v| [k.to_s.downcase.gsub(/\s/,"_").to_sym, v] }]
  end

  def init_index(type)
    type = type.to_s
    begin
      model_path = File.join(File.dirname(__FILE__),"models/#{type}.rb")
      require model_path
      model = type.capitalize.constantize
      client = model.gateway.client
      index_name = model.index_name

      #TODO: define where logger needs to happen
      #client.transport.logger.formatter = proc { |s, d, p, m| "\e[2m# #{m}\n\e[0m" }

      client.indices.delete index: index_name rescue nil
      client.indices.create index: index_name, body: {
        settings: model.settings.to_hash, 
        mappings: model.mappings.to_hash
      }

      puts "Initialized #{index_name} index"
    #rescue Elasticsearch::Transport::Transport::Errors::NotFound
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
  end


  # Mirrors the enqueue behavior of Clowder's Utility.enqueue_extracts(home)
  def cli_extract(extract, path, label, store)
    #def perform(extract, path, label, store)
    #end

    begin

    #worker_name = "#{extract.capitalize}Worker"
    #worker_path = File.join(File.dirname(__FILE__), "worker", worker_name)

      require File.join(File.dirname(__FILE__),
                      "workers/#{extract.downcase}_worker.rb")

      require File.join(File.dirname(__FILE__),
                      "extractors/#{extract.downcase}_extractor.rb")

      extractor = "#{extract.capitalize}Extractor".constantize
      worker = "#{extract.capitalize}Worker".constantize
      bulk = extractor::BULK

      require "awesome_print"
      if extract == "WELL"
        puts "got to WELL"

        extractor.parcels(path).each do |job|
          docs = extractor.new(
            project: path,
            label: label
          ).extract(job[:bulk], job[:mark])

          ap docs
          #WellWorker.perform_async(path, label, store, job[:bulk], job[:mark])
        end

      end

      #worker.perform(path, label, store)

      #WellExtractor.parcels(path).each do |job|
      #  WellWorker.perform_async(path, label, store, job[:bulk], job[:mark])
      #end

    #puts worker_path

    #worker = worker_name.constantize

    #begin
    #  if extract == "META"
    #    puts "THE EXTRACT WAS META"
    #    #worker.perform_later(path, label, store)
#
#        #MetaWorker.perform_async(path, label, store)
#      elsif extract == "WELL"
#        puts "THE EXTRACT WAS WELL"
#
#        #WellExtractor.parcels(path).each do |job|
#        #  WellWorker.perform_async(path, label, store, job[:bulk], job[:mark])
#        #end
#
#      end

    rescue Exception => e
      puts e
    end
  end



  # The string identifying a remote worker's semaphore
  #def qid(args)
  #  "#{args['queue']}_#{args['worker']}_#{args['jid']}".gsub(/\s/,'').downcase
  #end
  

end

