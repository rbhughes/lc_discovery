require "filesize"
require "nokogiri"
require "date"

require_relative "../sybase"
require_relative "../discovery"
require_relative "../utility"

require_relative "../models/meta"

class MetaExtractor

  attr_accessor :project, :label

  def initialize(opts)
    @project = opts[:project]
    @label = opts[:label]
    @gxdb = nil
  end

  #def count
  #end

  def extract

    begin
      puts "meta --> #{@project}"

      project_server = Discovery.parse_host(@project)
      project_home = Discovery.parse_home(@project)
      project_name = File.basename(@project)

      germ = "#{@project} #{@label}" #ensure this matches clowder

      doc = {
        id: Utility.lc_id(germ),
        label: @label,
        project: @project,
        project_server: project_server,
        project_home: project_home,
        project_name: project_name
      }

      @gxdb = Sybase.new(@project).db

      doc.merge! interpreters
      print "."
      doc.merge! version_and_coordsys
      print "."
      doc.merge! file_stats
      print "."
      doc.merge! db_stats
      print "."
      doc[:surface_bounds] = surface_bounds
      print "."
      puts

      # an average of non-null ages, both file and db
      ages = doc.select{ |k,v| k.to_s.match /^age/ }.values.compact
      doc = doc.reject{ |k,v| k.to_s.match /^age/ }
      doc[:activity_score] = ages.inject(:+)/ages.size

      doc

    rescue Exception => e
      puts e.message
      puts e.backtrace
      raise e
    ensure
      @gxdb.disconnect if @gxdb
      @gxdb = @project = @label = nil
    end

  end



  private

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
    pxml = File.join(@project, "Project.ggx.xml")
    return unless File.exists?(pxml)

    f = File.open(pxml)
    doc = Nokogiri::XML(f)
    f.close

    schema_vers = doc.xpath("ggx/Project/ProjectVersion").inner_text
    db_sys = doc.xpath("ggx/Project/StorageCoordinateSystem/GGXC1").inner_text
    map_sys = doc.xpath("ggx/Project/DisplayCoordinateSystem/GGXC1").inner_text
    esri_sys = doc.xpath("ggx/Project/DisplayCoordinateSystem/ESRI").inner_text
    unit_sys = doc.xpath("ggx/Project/UnitSystem").inner_text

    {
      schema_version: schema_vers.squeeze,
      db_coordsys: db_sys.squeeze,
      map_coordsys: map_sys.squeeze,
      esri_coordsys: "ESRI::"+esri_sys.squeeze,
      unit_system: unit_sys.squeeze
    }
  end

  #----------
  def file_stats
    dir = File.join(@project, "**/*")

    map_num, sei_num, file_count, byte_size = 0, 0, 0, 0 
    sei_ago, map_ago, file_ago = [], [], []

    oldest_file_mod = Time.now
    newest_file_mod = Time.at(0)

    Dir.glob(dir, File::FNM_DOTMATCH).each do |f| 
      next unless File.exists?(f)
      stat = File.stat(f)
      days_ago = ((Time.now.to_i - stat.mtime.to_i) / 86400).to_i
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
  def db_stats
    stats = {}

    sql = "select WC, WD, DC, DD, RC, RD, FC, FD, ZC, ZD, YC, YD "\
      "from (select count(*) as WC from well) wc "\
      "cross join "\
      "(select cast(avg(getdate()-row_changed_date) as integer) "\
      "as WD from well) wd "\
      "cross join "\
      "(select count(*) as DC from gx_well_curve) dc "\
      "cross join "\
      "(select cast(avg(getdate()-date_modified) as integer) "\
      "as DD from gx_well_curve) dd "\
      "cross join "\
      "(select count(*) as RC from log_image_reg_log_section) rc "\
      "cross join "\
      "(select cast(avg(getdate()-update_date) as integer) "\
      "as RD from log_image_reg_log_section) rd "\
      "cross join "\
      "(select count(distinct(source+formation)) as FC from formations) fc "\
      "cross join "\
      "(select cast(avg(getdate()-f.[Row Changed Date]) "\
      "as integer) as FD from formations f) fd "\
      "cross join "\
      "(select count(distinct z.[Attribute Name]) "\
      "as ZC from wellzoneintrvvaluewithdepthsouterjoin z) zc "\
      "cross join "\
      "(select cast(avg(getdate()-z.[Data Date]) as integer) "\
      "as ZD from wellzoneintrvvaluewithdepthsouterjoin z) zd "\
      "cross join "\
      "(select count(distinct y.[Survey ID]) as YC from wellsurveys y) yc "\
      "cross join "\
      "(select cast(avg(getdate()-y.[Row Changed Date]) as integer) "\
      "as YD from wellsurveydir y) yd"

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
