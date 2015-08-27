require "redis"
require "yaml"
require_relative "lc_env"

module RedisQueue

  def self.redis
    @redis ||= Redis.new url: LcEnv.redis_url
  end

end
