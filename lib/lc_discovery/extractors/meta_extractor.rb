require "filesize"
require "nokogiri"
require "date"
require_relative "../discovery"
require_relative "../utility"
require_relative "../models/meta"

class MetaExtractor
  include Discovery

  attr_accessor :project, :label, :gxdb
  BULK = 10

  #----------
  def initialize(opts)
    return unless File.exists?(opts[:project])
    super # inits a gxdb ref from Discovery
    @project = opts[:project]
    @label = opts[:label]
  end


  #def self.test_extract(opts)
  #  @project = opts[:project]
  #  @label = opts[:label]
  #  @gxdb = Discovery.gxdb(opts[:project])
  #  
  #  puts "___________________________"
  #  puts @gxdb
  #  puts "___________________________"
  #  #extract
  #end



  #----------
  def extract
    begin
      return [] unless (@project && @gxdb)

      #puts "meta --> #{@project}"

      doc = Utility.base_doc(@project, @label)

      germ = "#{@project} #{@label}" # must match clowder
      doc[:id] = Utility.lc_id(germ)

      doc.merge!(interpreters)
      doc.merge!(version_and_coordsys)
      doc.merge!(proj_file_stats)
      doc.merge!(proj_db_stats)

      doc[:surface_bounds] = surface_bounds
      doc[:activity_score] = activity_score(doc)

      [doc] # array to be consistent with other extractors

    rescue Exception => e
      puts e.message
      puts e.backtrace
      raise e
    ensure
      @gxdb.disconnect if @gxdb
    end

  end



  #----------
  def activity_score(doc)
    ages = doc.select{ |k,v| k.to_s.match /^age/ }.values.compact
    doc = doc.reject{ |k,v| k.to_s.match /^age/ }
    ages.inject(:+)/ages.size rescue nil
  end


  #----------
  def interpreters
    uf = File.join(@project, "User Files")
    return {interpreters: []} unless File.exists?(uf)
    #intrps = Dir.glob(File.join(uf,"*")).map{ |f| File.basename(f) }.join(", ")
    intrps = Dir.glob(File.join(uf,"*")).map{ |f| File.basename(f) }
    { interpreters: intrps }
  end

  #----------
  def version_and_coordsys
    geo = {
      schema_version: "ggx/Project/ProjectVersion",
      db_coordsys:    "ggx/Project/StorageCoordinateSystem/GGXC1",
      map_coordsys:   "ggx/Project/DisplayCoordinateSystem/GGXC1",
      esri_coordsys:  "ggx/Project/DisplayCoordinateSystem/ESRI",
      unit_system:    "ggx/Project/UnitSystem"
    }
    pxml = File.join(@project, "Project.ggx.xml")
    return geo.update(geo){ |k,v| v = nil } unless File.exists?(pxml)
    f = File.open(pxml)
    doc = Nokogiri::XML(f)
    f.close
    geo.update(geo){ |k,v| doc.xpath(v).inner_text.squeeze(" ") }
  end


  #----------
  def days_since(mtime)
    ((Time.now.to_i - mtime.to_i) / 86400).to_i
  end


  # ugly, but glob seems to offer best peformance. Maybe do native powershell?
  def proj_file_stats

    map_num, sei_num, file_count, byte_size = 0, 0, 0, 0 
    sei_ago, map_ago, file_ago = [], [], []

    oldest_file_mod = Time.now
    newest_file_mod = Time.at(0)

    Dir.glob(File.join(@project, "**/*"), File::FNM_DOTMATCH).each do |f| 
      next unless File.exists?(f)
      stat = File.stat(f)

      days_ago = days_since(stat.mtime)

      byte_size += stat.size
      file_count += 1 if File.file?(f)
      oldest_file_mod = stat.mtime if stat.mtime < oldest_file_mod
      newest_file_mod = stat.mtime if stat.mtime > newest_file_mod

      file_ago << days_ago unless f.match /gxdb.*\.(db|log)$/i

      if f.match /\interp\.svx$/i
        sei_num += 1
        sei_ago << days_ago
      end

      if f.match /\.(gmp|shp)$/i
        map_num += 1
        map_ago << days_ago
      end

    end

    age_layers_maps = (map_ago.inject(:+).to_f / map_ago.size).round rescue nil
    age_sv_interps = (sei_ago.inject(:+).to_f / sei_ago.size).round rescue nil
    age_file_mod = (file_ago.inject(:+).to_f / file_ago.size).round rescue nil

    {
      num_layers_maps: map_num,
      num_sv_interps: sei_num,
      oldest_file_mod: oldest_file_mod.utc.iso8601,
      newest_file_mod: newest_file_mod.utc.iso8601,
      byte_size: byte_size,
      human_size: Filesize.from("#{byte_size} B").pretty.gsub("i",""),
      file_count: file_count,
      age_layers_maps: age_layers_maps,
      age_sv_interps: age_sv_interps,
      age_file_mod: age_file_mod
    }

  end


  #----------
  def proj_db_stats
    stats = {}

    sql = "select WC, WD, DC, DD, RC, RD, FC, FD, ZC, ZD, YC, YD from "\
      "(select count(*) as WC "\
      "from well) a "\
      "cross join "\
      "(select cast(avg(getdate()-row_changed_date) as integer) as WD "\
      "from well) b "\
      "cross join "\
      "(select count(*) as DC "\
      "from gx_well_curve) c "\
      "cross join "\
      "(select cast(avg(getdate()-date_modified) as integer) as DD "\
      "from gx_well_curve) d "\
      "cross join "\
      "(select count(*) as RC "\
      "from log_image_reg_log_section) e "\
      "cross join "\
      "(select cast(avg(getdate()-update_date) as integer) as RD "\
      "from log_image_reg_log_section) f "\
      "cross join "\
      "(select count(distinct(source+form_id)) as FC "\
      "from well_formation) g "\
      "cross join "\
      "(select cast(avg(getdate()-row_changed_date) as integer) as FD "\
      "from well_formation) h "\
      "cross join "\
      "(select count(distinct(zone_name+zattribute_name)) as ZC "\
      "from well_zone_intrvl_value) i "\
      "cross join "\
      "(select cast(avg(getdate()-row_changed_date) as integer) as ZD "\
      "from well_zone_intrvl_value) j "\
      "cross join "\
      "(select count(distinct(source+survey_id)) as YC "\
      "from well_dir_srvy_station) k "\
      "cross join "\
      "(select cast(avg(getdate()-row_changed_date) as integer) as YD "\
      "from well_dir_srvy_station) l "

    @gxdb[sql].all.each do |x|
      stats[:num_wells]       = x[:wc]
      stats[:age_wells]       = x[:wd]
      stats[:num_vectors]     = x[:dc]
      stats[:age_vectors]     = x[:dd]
      stats[:num_rasters]     = x[:rc]
      stats[:age_rasters]     = x[:rd]
      stats[:num_formations]  = x[:fc]
      stats[:age_formations]  = x[:fd]
      stats[:num_zone_attr]   = x[:zc]
      stats[:age_zone_attr]   = x[:zd]
      stats[:num_dir_surveys] = x[:yc]
      stats[:age_dir_surveys] = x[:yd]
    end

    stats

  end

  #----------
  # NOTE: this still permits zeros, which are valid but likely goofs
  def surface_bounds

    sql = "select "\
      "min(surface_longitude) as min_longitude, "\
      "min(surface_latitude) as min_latitude, "\
      "max(surface_longitude) as max_longitude, "\
      "max(surface_latitude) as max_latitude "\
      "from well where "\
      "surface_longitude between -180 and 180 and "\
      "surface_latitude between -90 and 90 and "\
      "surface_longitude is not null and "\
      "surface_latitude is not null"

    corners = @gxdb[sql].all[0]

    {
      name: "surface_bounds",
      location: {
        type: "polygon",
        coordinates: [[
          [corners[:min_longitude], corners[:min_latitude]], #LL
          [corners[:min_longitude], corners[:max_latitude]], #UL
          [corners[:max_longitude], corners[:max_latitude]], #UR
          [corners[:max_longitude], corners[:min_latitude]], #LR
          [corners[:min_longitude], corners[:min_latitude]]  #LL
        ]]
      }
    }
  end

end
