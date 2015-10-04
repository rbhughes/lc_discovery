require_relative "./redis_queue"
require_relative "./utility"
require "awesome_print"

# may include writing to SQL files, CSVs or actual insert jobs (?)
module Publisher

  def self.write(type, docs, store)
    return if docs.empty? #TODO check this behavior

    model = Utility.invoke_lc_model(type)

    msg = "Writing #{docs.size} #{model} docs to #{store}."
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
      RedisQueue.redis.publish("lc_relay", e.message)
      puts "-"*50
      puts e.class
      puts e.backtrace.inspect
      puts "-"*50
    end
  end

end
