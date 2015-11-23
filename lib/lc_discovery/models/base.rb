require_relative "../lc_env"
require_relative "../utility"

require 'redis-objects'
require "awesome_print"

#####
# The base class of all LogicalCat models. This class contains a core set of 
# values that identifies the source GeoGraphix Discovery project. It also
# includes methods for creating, finding and deleting redis-objects. Descendents
# of the Base class have an lc_id value (same as @id) that is analogous to
# a natural key unique row id in a traditional RDBMS.
#
# * *label*:: A user-defined string used to "tag" this objectj
# * *project_id*:: Composite string: <label>:<project_host>:<norm_proj_path>
# * *project_home*:: Discovery Project Home and/or directory containing project
# * *project_host*:: The hostname of the PC (server) hosting a project
# * *project_path*:: Non-normalized drive letter or UNC path to a project
#
class Base
  include Redis::Objects

  attr_reader :id

  value :lc_id,        ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :label,        ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_id,   ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_name, ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_home, ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_host, ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_path, ilk: :base, expiration: Utility::REDIS_EXPIRY

  ############################################################################

  ###
  # Create a new object (probably a child of Base) and store it in Redis.
  #
  # Note: the +id+ string also gets stored in lc_id key so that we can search
  # for it later; +lc_id+ does not exist until the +populate+ method is called.
  #
  # :: *id* <String> a sort of natual key identifying the project and object
  # A typical lc_id key structure:
  #
  # <code>model_type:project_id+:<model-specific-id-field(s)>:lc_id</code>
  #
  # ...where +project_id+ is a composite of:
  #
  # <code>label:project_host:normalized_project_path</code>
  def initialize(id)
    # self.redis.select 1  #assign to a different database
    @id = id
  end

  ###
  # A newly created base object will only have +lc_id+ populated, This method
  # reads from a doc hash and fills in all the other attributes
  #
  # :: *doc* <Hash> probably generated from by an Extractor
  def populate(doc)
    Base.redis_objects.select{|k,v| v[:ilk] == :base}.each do |k,v|
      self.method("#{k}=").call(doc[k])
    end
    self.redis_objects.select{|k,v| v[:type] == :value && v[:ilk]}.each do |k,v|
      self.method("#{k}=").call(doc[k])
    end
    self.redis_objects.select{|k,v| v[:type] == :set}.each do |k,v|
      doc[k].each { |v| self.instance_eval("#{k}<<'#{v}'") }
    end
    self.lc_id = self.id
  end

  ###
  # Build a hash from this redis-object with all of its keys, parent and child
  # included. Any value that passes for numeric will be presented as numeric.
  def to_hash
    h = {}
    self.all_redis_objects.each do |o|
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

  ###
  # Attempt to convert string Numerics into actual integers or floats. Used by
  # +to_hash+.
  def try_a_number(v)
    ((float = Float(v)) && (float % 1.0 == 0) ? float.to_i : float) rescue v
  end

  ###
  # Delete this redis-object and all of its fields, parent and child included.
  # :: *return* <Boolean> +true+ if the object was deleted, +false+ if not.
  def delete
    (self.redis_objects.merge(Base.redis_objects)).each do |o|
      field = o[0]
      self.method(field).call.del
    end
    return Base.exists?(self) ? false : true
  end

  ###
  # Convenience method to collect both parent and child redis-objects
  def all_redis_objects
    Base.redis_objects.merge(self.redis_objects)
  end


  ############################################################################


  ###
  # Convenience method to collect both parent and child redis-objects
  def self.all_redis_objects
    Base.redis_objects.merge(self.redis_objects)
  end

  ###
  # Find the redis-object with this lc_id and delete it and all members
  # :: *lc_id* <String> the redis-object's lc_id
  # :: *return* <Number> +count+ of deleted objects, similar to ActiveRecord
  def self.delete(lc_id)
    self.find(lc_id).each { |o| o.delete }.size
  end

  ###
  # Construct a string that tries to match lc_id keys. If any of the hash args 
  # are sub-components of project_id (:label, :project_host, :norm_proj_path),
  # include them instead of project_id.
  # :: *args* <Hash> keys/values of fields used to match lc_id
  #
  # Used by Redis SCAN matcher--a glob-type-thing rather than true regex
  def self.matcher_string(args)
    # TODO: check escaping ":" character
    proj_id_fields = [:label, :project_host, :norm_project_path]
    if (args.keys & proj_id_fields).empty?
      fields = self.id_fields
    else
      fields = proj_id_fields + self.id_fields.reject{ |x| x == :project_id }
    end
    # set default values to "*"
    defaults = (Hash[fields.map {|x| [x, "*"]}])
    # replace "*" with values present in args
    defaults.update(args.select { |k| defaults.key? k }) # 
    # make it look like a redis lc_id key
    "#{self.to_s.downcase}:#{defaults.values.join(":")}:lc_id"
  end

  
  ###
  # Use Redis SCAN to match fields in +lc_id+ keys (see _matcher_string_).
  # :: *args* <Hash> keys/values of fields used to match lc_id
  # :: *return* <Array> of redis-objects (sort of like ruby hashes)
  # If found, full redis-object(s) are retrieved and returned.
  def self.find_by(args)
    if args.is_a?(Hash)
      matcher = matcher_string(args)
      cursor = 0
      all_keys = []
      found = []
      loop {
        cursor, keys = self.redis.scan cursor, :match => matcher
        all_keys += keys
        break if cursor == "0"
      }
      all_keys.each do |key|
        lc_id = self.redis.get key
        found << lc_id if self.exists?(lc_id) && ! found.include?(lc_id)
      end
      found.map{|id| self.new(id)}
    else
      self.find(args)
    end
  end

  ###
  # Retrieve any redis-objects given an array (or string) of lc_ids
  # :: *args* <Array> or <String> of +lc_id+ key strings
  # :: *return* <Array> of redis-objects (sort of like ruby hashes)
  def self.find(*args)
    found = []
    args.flatten.each do |o|
      lc_id = parse_id(o)
      found << lc_id if self.exists?(lc_id) && ! found.include?(lc_id)
    end
    #NOTE: self.new to simply retrieve an object is not active-recordy. beware!
    found.map{|id| self.new(id)}
  end

  ###
  # Parse and return the lc_id string for doc hashes, strings, or Base-children
  # :: *args* one of <Hash>, <String>, or <child of Base>
  def self.parse_id(obj)
    if obj.is_a? Hash                         # assume doc hash from extractor
      lc_id = self.gen_id(obj)
    elsif obj.is_a? String                    # assume an id string
      lc_id = obj
    elsif obj.class.superclass.name == "Base" # assume child of Base (lc model)
      lc_id = obj.id 
    end
    lc_id
  end

  ###
  # Check if the passed arg matches any redis-object's lc_id.
  # :: *obj* accepts extractor <Hash> lc_id <String> or <Child of Base>
  # :: *return* <Boolean> +true+ if a redis-object with the lc_id was found
  def self.exists?(obj)
    self.redis.exists "#{self.to_s.downcase}:#{parse_id(obj)}:lc_id"
  end

end
