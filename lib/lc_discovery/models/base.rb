require_relative "../lc_env"

require 'redis-objects'
require "awesome_print"

class Base
  include Redis::Objects

  #attr_reader :id
  #value :lc_id, expiration: Utility::REDIS_EXPIRY

  value :label,              ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_id,         ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_name,       ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_home,       ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_host,       ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_path,       ilk: :base, expiration: Utility::REDIS_EXPIRY

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
  # combine the base_matcher (project_id) with whatever each lc model uses to
  # establish uniqueness as defined by their self.matcher_fields method
  def self.matcher_string(args)
    #fields = [:label, :project_host, :norm_proj_path] + self.matcher_fields

    fields = (args[:project_id] ? [:project_id] : 
      [:label, :project_host, :norm_proj_path]) + self.matcher_fields

    # set default values to "*"
    defaults = (Hash[fields.map {|x| [x, "*"]}])

    # replace "*" with values present in args
    defaults.update(args.select { |k| defaults.key? k }) # 

    # make it look like a redis key
    defaults.values.join(":")
  end


  def self.find_by(args)
    if args.is_a?(Hash)
      #matcher = "#{self.to_s.downcase}:*#{matcher_string(args)}*:lc_id"
      matcher = matcher_string(args)

      cursor = 0
      all_keys = []
      hits = []

      ap "matcher=|#{matcher}|"

      loop {
        cursor, keys = self.redis.scan cursor, :match => matcher
        all_keys += keys
        break if cursor == "0"
      }

      all_keys.each do |key|
        lc_id = self.redis.get key
        ap "POST_SCAN -->    #{lc_id}"
        #ap "..."
        #ap self.find(lc_id)
        #ap "..."
      end

    else
      self.find(args)
    end
  end

  #----------
  # Find and retrieve an array of lc models by searching for the lc_id. Since
  # each lc_id contains: <label> : <host> : <path_string>, match on those if
  # they are supplied as hash options. Treat args as an lc_id string otherwise.
  def self.find(args)

    if args.is_a?(Array)

      cursor = 0
      all_keys = []
      hits = []

      loop {
        cursor, keys = self.redis.scan cursor
        all_keys += keys
        break if cursor == "0"
      }

      all_keys.each do |key|
        lc_id = self.redis.get key
        ap "-----------"
        ap self.find(lc_id)
        #hits << self.find(lc_id)[0]
        #ap "POST_SCAN -->    #{lc_id}"
        #ap "..."
        #ap self.find(lc_id)
        #ap "..."
      end
      #hits

    else
      self.exists?(args) ? [self.new(args)] : []
    end

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
