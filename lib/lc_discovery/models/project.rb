require_relative "../lc_env"
require_relative "../utility"

require 'redis-objects'
require "awesome_print"

class Project
  include Redis::Objects

  attr_reader :id
  value :lc_id, expiration: Utility::REDIS_EXPIRY
  
  value :label,           ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_id,      ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_name,    ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_home,    ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_host,    ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_path,    ilk: :base, expiration: Utility::REDIS_EXPIRY

  value :db_coordsys,     ilk: :geo,  expiration: Utility::REDIS_EXPIRY
  value :map_coordsys,    ilk: :geo,  expiration: Utility::REDIS_EXPIRY
  value :esri_coordsys,   ilk: :geo,  expiration: Utility::REDIS_EXPIRY
  value :unit_system,     ilk: :geo,  expiration: Utility::REDIS_EXPIRY
  value :surface_bounds,  ilk: :geo,  expiration: Utility::REDIS_EXPIRY

  value :activity_score,  ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :schema_version,  ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :oldest_file_mod, ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :newest_file_mod, ilk: :data, expiration: Utility::REDIS_EXPIRY
  set :interpreters,      ilk: :data, expiration: Utility::REDIS_EXPIRY

  value :byte_size,       ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :human_size,      ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :file_count,      ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :num_layers_maps, ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :num_sv_interps,  ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :num_wells,       ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :num_vectors,     ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :num_rasters,     ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :num_formations,  ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :num_zone_attr,   ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :num_dir_surveys, ilk: :data, expiration: Utility::REDIS_EXPIRY

  #----------
  def initialize(id)
    #self.redis.select 1  <-- if you want to assign it to a different database
    @id = id
    self.lc_id = id
  end


  #----------
  def populate(doc)
    self.redis_objects.select{|k,v| v[:type] == :value && v[:ilk]}.each do |k,v|
      self.method("#{k}=").call(doc[k])
    end
    
    self.redis_objects.select{|k,v| v[:type] == :set}.each do |k,v|
      doc[k].each { |v| self.instance_eval("#{k}<<'#{v}'") }
    end
  end
  

  #----------
  # calling project.num_wells (or any value) returns an instance of Redis::Value.
  # Yuck. Rather than calling .get on them later, create "get_<attr>" methods.
  # project.get_label --> "fakery"
  # project.get_num_wells --> 5 (an actual Fixnum, not a string)
  #FIELDS.keys.each do |f|
  #  class_eval("def get_#{f}; try_a_number(self.#{f}.get); end")
  #end


  #----------
  # Delete an object and all it's fields TODO: make more efficient?
  def purge(lc_id = self.id)
    if (doomed = Project.find(lc_id))
      doomed.redis_objects.each do |o|
        field = o[0]
        self.method(field).call.del
      end
    end
    return Project.exists?(doomed) ? false : true
  end


  #----------
  # messy but works
  def to_hash
    h = {}
    self.redis_objects.each do |o|
      field = o[0]
      redis_type = o[1][:type] 
      case redis_type
      when :value
        h[field] = try_a_number(self.method(field).call.value)
      when :set
        h[field] = self.method(field).call.members.map{ |x| try_a_number(x) }
      end

    end
    h
  end


  #----------
  def try_a_number(v)
    ((float = Float(v)) && (float % 1.0 == 0) ? float.to_i : float) rescue v
  end


  ############################################################################

  #----------
  def self.lc_id(doc)
    doc[:project_id] # just project_id since "Project" is just a project
  end

  #----------
  # watch out if lc_id exists the other attributes *probably* also exist
  # check for String or hash key (lc_id or id)
  def self.exists?(x)
    if x.is_a? Hash
      check = self.lc_id(x)
    elsif x.is_a? Project
      check = x.lc_id.get
    else
      check = x
    end
    self.redis.exists "project:#{check}:lc_id"
  end

  #----------
  def self.field_names
    self.redis_objects.select{|k,v| v[:ilk]}.keys
  end

  #----------
  # returns reference to this key only if it exists
  def self.find(lc_id)
    self.exists?(lc_id) ? self.new(lc_id) : nil
  end

  #----------
  def self.find_all(args)
    #parse args and search by attribtes with AND qualifier
    ap args

  end


  Redis::Objects.redis = Utility.redis_pool
  
end
