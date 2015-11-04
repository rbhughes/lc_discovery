#require "elasticsearch/persistence/model"
require_relative "../lc_env"
require_relative "../utility"

require 'redis-objects'
require "awesome_print"


class Meta
  include Redis::Objects

  attr_reader :id

  ID_VALUES = [
    :label,
    :project_id,
    :project_name,
    :project_home,
    :project_host,
    :project_path
  ]

  VALUES = [
    :schema_version,
    :db_coordsys,
    :map_coordsys,
    :esri_coordsys,
    :unit_system,
    :oldest_file_mod,
    :newest_file_mod,
    :byte_size,
    :human_size,
    :file_count,
    :num_layers_maps,
    :num_sv_interps,
    :num_wells,
    :num_vectors,
    :num_rasters,
    :num_formations,
    :num_zone_attr,
    :num_dir_surveys,
    :activity_score,
    :surface_bounds #TODO make it a real GEO thing later
  ]

  SETS = [
    :interpreters
  ]


  def initialize(obj)
    #self.redis.select 1 #if you want to assign it to a different database

    @id = redis_key(obj)

    obj.each_pair do |k,v|

      if (ID_VALUES + VALUES).include?(k)
        self.class.value(k, expiration: Utility::REDIS_EXPIRY)
        m = self.method("#{k}=")
        m.call(v)
      end

      if SETS.include?(k)
        self.class.set(k, expiration: Utility::REDIS_EXPIRY)
        self.instance_eval("#{k}<<#{v}")
      end

    end

  end


  #----------
  # equivalent to Utility.project_key since this is a project type thing
  def redis_key(obj)
    Utility.project_key(obj[:project_path], obj[:label])
  end


  #----------
  # messy, but works
  def to_hash
    h = {}
    self.redis_objects.each do |o|
      field = o[0]
      redis_type = o[1][:type] 
      case redis_type
      when :value
        h[field] = try_a_number(self._method(field).call.value)
      when :set
        h[field] = self._method(field).call.members.map{ |x| try_a_number(x) }
      end

    end
    h
  end

  def try_a_number(v)
    ((float = Float(v)) && (float % 1.0 == 0) ? float.to_i : float) rescue v
  end

  def self.key_names
    ID_VALUES + (VALUES + SETS).sort
  end


  Redis::Objects.redis = Utility.redis_pool
  
end
