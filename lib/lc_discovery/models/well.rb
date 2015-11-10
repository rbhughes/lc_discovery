require_relative "../lc_env"

require 'redis-objects'
require "awesome_print"

class Well
  include Redis::Objects

  attr_reader :id
  value :lc_id, expiration: Utility::REDIS_EXPIRY

  value :label,              ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_id,         ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_name,       ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_home,       ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_host,       ilk: :base, expiration: Utility::REDIS_EXPIRY
  value :project_path,       ilk: :base, expiration: Utility::REDIS_EXPIRY

  value :well_id,            ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :source,             ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :operator,           ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :state,              ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :county,             ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :country,            ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :well_name,          ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :well_number,        ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :common_well_name,   ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :latitude,           ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :longitude,          ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :lat,                ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :lng,                ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :status,             ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :classification,     ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :datum_elev,         ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :ground_elev,        ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :plugback_depth,     ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :td,                 ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :fm_at_td,           ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :fm_alias_at_td,     ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :spud_date,          ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :comp_date,          ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :data_date,          ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :area,               ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :district,           ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :field,              ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :permit_number,      ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :datum_type,         ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :alternate_id,       ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :old_id,             ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :user_1,             ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :user_2,             ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :lease_name,         ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :platform_id,        ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :water_depth,        ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :water_datum,        ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :parent_uwi_type,    ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :permit_date,        ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :user_date,          ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :parent_uwi,         ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :legal_survey_type,  ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :location,           ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :percent_allocation, ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :location,           ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :row_changed_date,   ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :original_operator,  ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :internal_status,    ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :wsn,                ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :surface_point,      ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :proposed,           ilk: :data, expiration: Utility::REDIS_EXPIRY


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
  # Delete an object and all it's fields TODO: make more efficient?
  def purge(lc_id = self.id)
    if (doomed = Meta.find(lc_id))
      doomed.redis_objects.each do |o|
        field = o[0]
        self.method(field).call.del
      end
    end
    return Meta.exists?(doomed) ? false : true
  end

end
