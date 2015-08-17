require "filesize"
#require "nokogiri"
#require "date"

require_relative "../sybase"
require_relative "../discovery"
require_relative "../utility"

require_relative "../models/well"

class WellExtractor

  attr_accessor :project, :label
  BULK = 500

  def initialize(opts)
    @project = opts[:project]
    @label = opts[:label]
    @gxdb = nil
  end

  # divide the job into sub-tasks based on size.
  # This should get called once by dispatcher
  def self.parcels(project, bulk=BULK)
    begin
      gxdb = Sybase.new(project).db
      count = gxdb[:wellheader].count
      jobs = []
      (1..count).step(bulk) { |mark| jobs << {bulk: bulk, mark: mark} }
      jobs
    rescue Exception => e
      puts e.message
      puts e.backtrace
      raise e
    ensure
      gxdb.disconnect if gxdb
      gxdb = nil
    end
  end



  #----------
  def extract(bulk, mark)

    begin
      puts "well --> #{@project} [bulk=#{bulk} mark=#{mark}]"

      project_server = Discovery.parse_host(@project)
      project_home = Discovery.parse_home(@project)
      project_name = File.basename(@project)
      proj_id = Utility.lc_id("#{@project} #{@label}") #should match clowder

      @gxdb = Sybase.new(@project).db

      sql = "select top #{bulk} start at #{mark} * from WellHeader \
      order by WellHeader.[Well ID]"
      
      docs = []
      @gxdb[sql].each do |row|

        #transform symbols to use underscores, no quotes, lowercase
        row = Utility.lowercase_symbol_keys(row)

        #germ = "#{@project} #{@label} #{row[:"well id"]}"
        germ = "#{@project} #{@label} #{row[:well_id]}"

        doc = {
          id: Utility.lc_id(germ),
          project_id: proj_id,
          label: @label,
          project: @project,
          project_server: project_server,
          project_home: project_home,
          project_name: project_name
        }

        docs << doc.merge(row)


      end

      return docs


    rescue Exception => e
      puts e.message
      puts e.backtrace
      raise e
    ensure
      @gxdb.disconnect if @gxdb
      @gxdb = @project = @label = nil
    end

  end




end
