require "sequel"
require "socket"
require "yaml"
require_relative "discovery"

require "yaml"
require "sequel"

class Sybase
  GGX_SYBASE = "C:/Program Files (x86)/GeoGraphix/SQL Anywhere 12/BIN64"

  attr_reader :db

  # The GGX path will usually be present. If not, append to PATH from config.yml
  def initialize(proj)
    begin
      @db = Sequel.sqlanywhere(conn_string: Discovery.connect_string(proj))
    rescue LoadError
      puts "Cannot find SQLAnywhere exes in PATH. Trying from config.yml..."
      config_path = File.join(
        File.expand_path("../../", File.dirname(__FILE__)), "config.yml")
      config = YAML.load_file(config_path)
      sybase_path = config["sybase"]["path"] ||= GGX_SYBASE
      ENV["PATH"] = "#{ENV["PATH"]};#{sybase_path}"
      retry
    rescue Exception => e
      raise e
    end
  end

  at_exit { @db.disconnect if @db }

end
