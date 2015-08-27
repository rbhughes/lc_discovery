require "sequel"
require "socket"
require "yaml"
require_relative "discovery"
require_relative "lc_env"

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
      ENV["PATH"] = "#{ENV["PATH"]};#{LcEnv.sybase_path}"
      retry
    rescue Exception => e
      raise e
    end
  end

  at_exit { @db.disconnect if @db }

end
