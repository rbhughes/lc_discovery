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

  

  #----------
  # calling project.num_wells (or any value) returns an instance of Redis::Value.
  # Yuck. Rather than calling .get on them later, create "get_<attr>" methods.
  # project.get_label --> "fakery"
  # project.get_num_wells --> 5 (an actual Fixnum, not a string)
  #FIELDS.keys.each do |f|
  #  class_eval("def get_#{f}; try_a_number(self.#{f}.get); end")
  #end




  #----------
#  # messy but works
#  def to_hash
#    h = {}
#    self.redis_objects.each do |o|
#      field = o[0]
#      redis_type = o[1][:type] 
#      case redis_type
#      when :value
#        h[field] = try_a_number(self.method(field).call.value)
#      when :set
#        h[field] = self.method(field).call.members.map{ |x| try_a_number(x) }
#      end
#
#    end
#    h
#  end


  #----------
#  def try_a_number(v)
#    ((float = Float(v)) && (float % 1.0 == 0) ? float.to_i : float) rescue v
#  end


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


  #----------
  # watch out if lc_id exists the other attributes *probably* also exist
  # check for String or hash key (lc_id or id)
#  def self.exists?(x)
#    if x.is_a? Hash
#      check = self.lc_id(x)
#    elsif x.is_a? Project
#      check = x.lc_id.get
#    else
#      check = x
#    end
#    self.redis.exists "project:#{check}:lc_id"
#  end

  #----------
#  def self.field_names
#    self.redis_objects.select{|k,v| v[:ilk]}.keys
#  end

  #----------
  # returns reference to this key only if it exists
  #def self.find(lc_id)
  #  super
  #  #self.exists?(lc_id) ? self.new(lc_id) : nil
  #end


  #----------
#  def self.find_all(args)
#    #parse args and search by attribtes with AND qualifier
#    ap args
#
#  end


  Redis::Objects.redis = Utility.redis_pool
  
end
