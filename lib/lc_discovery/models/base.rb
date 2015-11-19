require_relative "../lc_env"
require_relative "../utility"

require 'redis-objects'
require "awesome_print"

class Base
  include Redis::Objects

  #attr_reader :id
  #value :lc_id, expiration: Utility::REDIS_EXPIRY

  value :label,        ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_id,   ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_name, ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_home, ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_host, ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_path, ilk: :base, expiration: Utility::REDIS_EXPIRY

  #----------
  def initialize(id)
    #self.redis.select 1  <-- if you want to assign it to a different database
    @id = id
    self.lc_id = id
  end


  #----------
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
  end



  #----------
  def self.base_and_child_redis_objects(obj)
    return obj.redis_objects unless obj.class.superclass.name == "Base"
    obj.class.superclass.redis_objects.merge(obj.redis_objects)
  end
  
  #----------
  # messy but works
  def to_hash
    h = {}
    Base.base_and_child_redis_objects(self).each do |o|
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



  #----------
  # Delete an object and all it's fields TODO: make more efficient?
  # Also get base_doc fields
  #def purge(lc_id = self.id)
  #  if (doomed = self.class.find(lc_id))
  #    (doomed.redis_objects.merge(Base.redis_objects)).each do |o|
  #      field = o[0]
  #      self.method(field).call.del
  #    end
  #  end
  #  return Base.exists?(doomed) ? false : true
  #end


  def self.delete(lc_id)
    #ap self.class.find(self.id)[0]

  end

  def delete
    (self.redis_objects.merge(Base.redis_objects)).each do |o|
      field = o[0]
      self.method(field).call.del
    end
    return Base.exists?(self) ? false : true
  end




  ############################################################################


  #----------
  def self.field_names
    self.redis_objects.select{|k,v| v[:ilk]}.keys
  end


  #----------
  # Construct a string that tries to match lc_id keys. If any of the hash args 
  # are sub-components of project_id (:label, :project_host, :norm_proj_path),
  # include them instead of project_id.
  # TODO: check escaping ":" character
  def self.matcher_string(args)

    proj_id_fields = [:label, :project_host, :norm_project_path]

    if (args.keys & proj_id_fields).empty?
      fields = self.lc_id_fields
    else
      fields = proj_id_fields + self.lc_id_fields.reject{ |x| x == :project_id }
    end

    # set default values to "*"
    defaults = (Hash[fields.map {|x| [x, "*"]}])

    # replace "*" with values present in args
    defaults.update(args.select { |k| defaults.key? k }) # 

    # make it look like a redis lc_id key
    "#{self.to_s.downcase}:#{defaults.values.join(":")}:lc_id"
  end


  def self.find_by(args)
    if args.is_a?(Hash)
      matcher = matcher_string(args)

      cursor = 0
      all_keys = []
      hits = []

      loop {
        cursor, keys = self.redis.scan cursor, :match => matcher
        all_keys += keys
        break if cursor == "0"
      }

      all_keys.each do |key|
        lc_id = self.redis.get key
        hits << self.new(lc_id) if self.exists?(lc_id)
      end
      hits

    else
      self.find(args)
    end
  end


  #----------
  # Retrieve any valid models given an array (or string) of lc_ids
  def self.find(*args)
    hits = []
    args.flatten.each do |lc_id|
      hits << self.new(lc_id) if self.exists?(lc_id)
    end
    hits
  end



  #----------
  # Check if the passed arg matches any object's lc_id.
  def self.exists?(x)
    if x.is_a? Hash                         # assume doc hash from extractor
      lc_id = self.lc_id(x)
    elsif x.is_a? String                    # assume an lc_id of self
      lc_id = x
    elsif x.class.superclass.name == "Base" # assume child of Base (lc model)
      lc_id = x.lc_id.get 
    end

    self.redis.exists "#{self.to_s.downcase}:#{lc_id}:lc_id"
  end



end
