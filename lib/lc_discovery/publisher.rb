require_relative "./redis_queue"
require "awesome_print"

# may include writing to SQL files, CSVs or actual insert jobs (?)
module Publisher

  def self.write(type, docs, store)
    require_relative "./models/#{type}"
    model = type.capitalize.constantize

    msg = "Writing #{docs.size} #{type.capitalize} docs to #{store}."
    RedisQueue.redis.publish("lc_relay", msg)

    begin

      if store == "elasticsearch"
        docs.each { |doc| model.create(doc) }
      else #assume stdout for now
        ap docs
      end

    rescue Exception => e
      puts "*"*40
      puts e.message.to_s
      puts "*"*40
      RedisQueue.redis.publish(e.message)
      puts "-"*50
      puts e.class
      puts e.backtrace.inspect
      puts "-"*50
    end
  end

end
