require_relative "../lc_env"
require_relative "../utility"
require_relative "./base"

require 'redis-objects'
require "awesome_print"

# Extract metadata from Project objects. Unlike other models which represent
# specific E&P data types like Well Header or Directional Surveys, a Project
# represents the GeoGraphix Discovery project used to interpret data. 
class Project < Base
  include Redis::Objects
  self.redis_prefix = self.to_s.downcase
  
  value :db_coordsys,     ilk: :geo,  expiration: Utility::REDIS_EXPIRY
  value :map_coordsys,    ilk: :geo,  expiration: Utility::REDIS_EXPIRY
  value :esri_coordsys,   ilk: :geo,  expiration: Utility::REDIS_EXPIRY
  value :unit_system,     ilk: :geo,  expiration: Utility::REDIS_EXPIRY
  value :surface_bounds,  ilk: :geo,  expiration: Utility::REDIS_EXPIRY

  value :activity_score,  ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :schema_version,  ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :oldest_file_mod, ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :newest_file_mod, ilk: :data, expiration: Utility::REDIS_EXPIRY
  set   :interpreters,    ilk: :data, expiration: Utility::REDIS_EXPIRY

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

  def self.id_fields
    [:project_id]
  end

  def self.gen_id(doc)
    id_fields.map{ |x| doc[x] }.join(":")
  end

  def initialize(id)
    @id = id
  end

  Redis::Objects.redis = Utility.redis_pool
end
