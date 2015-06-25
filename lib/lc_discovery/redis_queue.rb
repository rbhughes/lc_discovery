#read these from a config file or elsewhere?
HOST = '127.0.0.1'
PORT = 6379
#Redis::Objects.redis ||= Redis.new(host: HOST, port: PORT)

# memoize as singleton_class, but with module (which is a class) right? right.
# http://tech.pro/tutorial/1149/understanding-method-lookup-in-ruby-20
module RedisQueue
  class << self
    def redis
      @redis ||= Redis.new(host: HOST, port: PORT)
      #@redis ||= Redis.new(:url => (ENV["REDIS_URL"] || 'redis://127.0.0.1:6379'))
    end
  end
end

