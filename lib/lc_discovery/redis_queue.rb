require "redis"
require "yaml"

module RedisQueue

  def self.redis
    @redis ||= 
      begin
        config_path = File.join(
          File.expand_path("../../", File.dirname(__FILE__)), "config.yml")
        config = YAML.load_file(config_path)
        host = config["redis"]["host"] ||= "127.0.0.1"
        port = config["redis"]["port"] ||= 6379
        Redis.new(host: host, port: port)
      rescue Exception => e
        puts e
      end
  end

end
