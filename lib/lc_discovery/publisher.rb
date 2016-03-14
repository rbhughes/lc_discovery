require "awesome_print"
require_relative "./utility.rb"


# may include writing to SQL files, CSVs or actual insert jobs (?)
class Publisher
  include Utility

  def write(type, docs, store)
    return if docs.empty? #TODO check this behavior

    model = Utility.invoke_model(type)

    begin

      if store == "redis"

        redis.publish("lc_relay", "publishing #{docs.size} #{model} doc(s)")
        docs.each do |doc|
          model.new(model.gen_id(doc)).populate(doc)
        end

      else #assume stdout
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
