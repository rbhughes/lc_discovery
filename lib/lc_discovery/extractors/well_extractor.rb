require "filesize"
require_relative "../discovery"
require_relative "../utility"
require_relative "../models/well"

class WellExtractor
  include Discovery

  attr_accessor :project, :label, :gxdb
  BULK = 500

  def initialize(opts)
    unless File.exists?(opts[:project])
      puts "Cannot access project: #{opts[:project]}"
      return
    end
    super
    @project = opts[:project]
    @label = opts[:label]
  end

  #----------
  # divide the job into sub-tasks based on size. Called once by dispatcher
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
      ###gxdb = nil
    end
  end


  #----------
  def extract(bulk, mark)

    begin
      #puts "well --> #{@project} [bulk=#{bulk} mark=#{mark}]"

      docs = []
      doc = Utility.base_doc(@project, @label)

      sql = "select top #{bulk} start at #{mark} * from WellHeader \
      order by WellHeader.[Well ID]"

      @gxdb[sql].each do |row|
        doc = doc.dup
        row = Utility.lowercase_symbol_keys(row)

        #germ = "#{@project} #{@label} #{row[:well_id]}"
        #doc[:id] = Utility.lc_id(germ)

        #TODO: ensure this is correct format and queryable
        doc[:surface_point] = {
          name: "surface_bounds",
          location: {
            type: "geo_point",
            location: {
              lat: row[:latitude], 
              lon: row[:longitude]
            }
          }
        }

        docs << doc.merge!(row)

      end

      return docs

    rescue Exception => e
      puts e.message
      puts e.backtrace
      raise e
    ensure
      @gxdb.disconnect if @gxdb
    end

  end


end
