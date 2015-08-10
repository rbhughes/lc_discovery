require 'digest/sha1'

# require all the elasticsearch models
#model_path = File.join(File.dirname(__FILE__),'models/*.rb')
#Dir[model_path].each { |file| require file }



module Utility

  module_function

  # Because backslashes are...irritating
  def fwd_slasher(s)
    s.strip.gsub('\\', '/') rescue nil
  end

  # Make a sort of guid, which in some cases is a natural key
  def lc_id(s)
    Digest::SHA1.hexdigest(fwd_slasher(s.downcase))
  end


  def camelized_class(str)
    str.to_s.split('_').map {|w| w.capitalize}.join.constantize
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


  # The string identifying a remote worker's semaphore
  #def qid(args)
  #  "#{args['queue']}_#{args['worker']}_#{args['jid']}".gsub(/\s/,'').downcase
  #end
  

end

