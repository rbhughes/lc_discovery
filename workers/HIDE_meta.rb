require "sidekiq"
require "awesome_print"
#require "sequel"
#require_relative "../lib/discovery/clowder.rb"

#ENV["PATH"]= "#{ENV["PATH"]};c:/dev/sqla64/bin64"

# If your client is single-threaded, we just need a single connection in our Redis connection pool
#Sidekiq.configure_client do |config|
#  config.redis = { :namespace => 'ichabod', :size => 1 }
#end

# Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
#Sidekiq.configure_server do |config|
#  config.redis = { :namespace => 'ichabod' }
#end



class Meta
  include Sidekiq::Worker
  def perform(lc_id=100)
    sleep 1
    ##s = "worker #{self.class} received #{lc_id} at #{Time.now}"
    #p = Project.where(:lc_id => lc_id).first

    #db = Sequel.sqlanywhere(:conn_string => p.connect_string)

    #dataset = db[:WellHeader].select(:"well id", :"well name", :"latitude")

    #rows = ""
    #dataset.each do |w|
    #  rows << "#{w}\n"
    #end

    rows = %w( meta aaaaa bbb );
    rows << lc_id
    rows << '________________'
    
    open("c:/temp/kiq/_OUTPUT.txt", "a") {|f| f.puts rows }
  end
end


#require_relative 'well'

