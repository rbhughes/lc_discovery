require_relative "./redis_queue"

# may include writing to SQL files, CSVs or actual insert jobs (?)
module Publisher

  def self.write(type, docs, store)
    require_relative "./models/#{type}"
    model = type.capitalize.constantize

    msg = "Writing #{docs.size} #{type.capitalize} docs to #{store}."
    RedisQueue.redis.publish("lc_relay", msg)

    begin

      docs.each do |doc|
        if store == "elasticsearch"
          model.create(doc)
        else
          puts "Need to PUBLISH #{docs.size} to #{store}"
        end
      end

    rescue Exception => e
      puts "*"*40
      puts e.message
      puts "*"*40
      #RedisQueue.redis.publish(e.message)
      puts "-"*50
      puts e.class
      puts e.backtrace.inspect
      puts "-"*50
    end
  end

end
