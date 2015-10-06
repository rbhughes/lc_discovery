require "yaml"

module LcEnv

  class Lookup
    GGX_SYBASE = "C:/Program Files (x86)/GeoGraphix/SQL Anywhere 12/BIN64"

    def self.config
      @config ||= get_config
    end

    def self.elasticsearch_url
      host = config["elasticsearch"]["host"] ||= "localhost"
      port = config["elasticsearch"]["port"] ||= 9200
      "http://#{host}:#{port}"
    end


    def self.redis_url
      host = config["redis"]["host"] ||= "localhost"
      port = config["redis"]["port"] ||= 6379
      "redis://#{host}:#{port}"
    end

    def self.sybase_path
      sybase_path = config["sybase"]["path"] ||= GGX_SYBASE
    end

    private

    def self.get_config
      begin
        config_path = File.join(
          File.expand_path("../../", File.dirname(__FILE__)), "config.yml")
        YAML.load_file(config_path)
      rescue Exception => e
        puts e
      end
    end

  end

  def self.elasticsearch_url
    Lookup.elasticsearch_url
  end


  def self.redis_url
    Lookup.redis_url
  end

  def self.sybase_path
    Lookup.sybase_path
  end


end
