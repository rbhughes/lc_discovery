require_relative "../lc_env"
require_relative "../utility"
require_relative "./base"

require 'redis-objects'
require "awesome_print"

class Project < Base
  include Redis::Objects

  attr_reader :id
  value :lc_id, expiration: Utility::REDIS_EXPIRY
  
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

  

  ############################################################################

  #----------
  # redis-objects will turn it into project:
  def self.lc_id(doc)
    doc[:project_id]
  end


  #----------
  # just return an empty array since doc[:project_id] is the basic matcher
  # Look in Base to see that it's really:
  # [:label, :project_host, :normalized_project_path]
  def self.matcher_fields
    []
  end



  Redis::Objects.redis = Utility.redis_pool
  
end
