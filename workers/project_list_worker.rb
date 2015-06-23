require "sidekiq"
require "awesome_print"


require_relative '../lib/lc_discovery/discovery.rb'

class ProjectListWorker
  include Sidekiq::Worker

  def perform(root='c:/programdata/geographix/projects', deep_scan=false)

    rows = []
    Discovery.project_list(root, deep_scan).each do |proj|
      rows << proj
    end

    ap rows


    ##s = "worker #{self.class} received #{lc_id} at #{Time.now}"
    #p = Project.where(:lc_id => lc_id).first

    #db = Sequel.sqlanywhere(:conn_string => p.connect_string)

    #dataset = db[:WellHeader].select(:"well id", :"well name", :"latitude")

    #rows = ""
    #dataset.each do |w|
    #  rows << "#{w}\n"
    #end

    #rows = %w( meta aaaaa bbb );
    #rows << lc_id
    #rows << '________________'

    
  end

  private

  def qid
    @qid ||= ['lc_discovery', self.class.name, self.jid].join('_').downcase
  end



end


#require_relative 'well'

