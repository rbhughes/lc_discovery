require "sequel"
require "socket"
require "yaml"
#require_relative "discovery"
require_relative "lc_env"

module Discovery

  class Sybase
    GGX_SYBASE = "C:/Program Files (x86)/GeoGraphix/SQL Anywhere 12/BIN64"

    attr_reader :db

    # We expect SqlAnywhere to be in the PATH from the Discovery installation 
    # If it isn't use the path from LcEnv
    def initialize(proj)
      tries ||= 3
      @db = Sequel.sqlanywhere(conn_string: Discovery.connect_string(proj))
    rescue LoadError
      puts "Cannot find SQLAnywhere exes in PATH. Trying from config.yml..."
      set_lcenv_sybase_path
      retry unless (tries -= 1).zero?
    rescue Exception => e
      raise e
    end

    def set_lcenv_sybase_path
      ENV["PATH"] = "#{ENV["PATH"]};#{LcEnv.sybase_path}"
    end

    at_exit { @db.disconnect if @db }
  end

  #----------
  def initialize(opts)
    @gxdb ||= Sybase.new(opts[:project]).db
  end


  #---------- 
  def self.project_list(root, deep_scan)
    root = root.gsub("\\","/")
    projects = []
    recurse = deep_scan ? "**" : "*"
    Dir.glob(File.join(root, recurse, "*.ggx")).each do |ggx|
      proj = File.dirname(ggx)
      projects << proj if ggx_project?(proj)
    end
    projects
  end



  # Build a connect string for Sybase that mimics Discovery
  # UID=dba;PWD=sql;DBF="\\OKC1GGX0006\e$\Oklahoma\NW Oklahoma/gxdb.db";
  # DBN=NW_Oklahoma-Oklahoma;HOST=OKC1GGX0006;Server=GGX_OKC1GGX0006
  #
  # There are other permutations of this that will work, but this one should
  # be non-blocking if using the project server as host.
  def self.connect_string(proj)
    host =  parse_host(proj)
    dbn = "#{File.basename(proj)}-#{parse_home(proj)}".gsub(" ", "_")
    conn = []
    conn << "UID=dba"
    conn << "PWD=sql"
    conn << "DBF='#{File.join(proj, 'gxdb.db')}'"
    conn << "DBN=#{dbn}"
    conn << "HOST=#{host}"
    conn << "SERVER=GGX_#{host}"
    conn.join(";")
  end



  # Simple check for database and Global AOI dir
  def self.ggx_project?(path)
    a = File.join(path, "gxdb.db")
    b = File.join(path, "global")
    c = File.join(path, "project.ggx")
    (File.exists?(a) && Dir.exists?(b) && File.exists?(c)) ? true : false
  end

  # Pluck the hostname from either the UNC path or localhost.
  # Replace backslashes with forward slashes for consistency
  # NOTE: Need to check the UNC spec to see if the match works in all cases
  def self.parse_host(proj)
    proj = proj.gsub("\\", "/")
    (proj.match(%r{^//})) ? (proj.match(%r{^//(\w+)}))[1] : Socket.gethostname
  end

  # Try to get home name from home.ini first; assume the root directory is the
  # Project Home otherwise
  def self.parse_home(proj)
    ini = File.join(File.dirname(proj), "home.ini")
    if File.exists?(ini)
      m = File.read(ini).match(/Name=(.*)/)
      return m[1]
      #m[1] ? m[1] : File.basename(File.dirname(proj))
    end
    File.basename(File.dirname(proj))
  end

  #  def total_bytes(path)
  #    dir = File.join(path, "**/*")
  #    Dir.glob(dir, File::FNM_DOTMATCH).select{|f| File.file?(f)}.map do |j|
  #      if File.exists?(j) && File.readable?(j)
  #        File.stat(j).size ||= 0
  #      else
  #        puts "COULD NOT READ  #{j}"
  #        0
  #      end
  #    end.inject(:+)
  #  end

end
