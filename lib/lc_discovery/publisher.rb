require "awesome_print"
require_relative "./utility.rb"


# may include writing to SQL files, CSVs or actual insert jobs (?)
class Publisher
  include Utility

  def write(type, docs, store)
    return if docs.empty? #TODO check this behavior

    model = Utility.invoke_lc_model(type)

    msg = "Writing #{docs.size} #{model} docs to #{store}."
    redis.publish("lc_relay", msg)

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
      puts e.backtrace.inspect
      redis.publish("lc_relay", e.message)
    end
  end

end
