require_relative "../lc_env"
require_relative "../utility"
require_relative "./base"

require "redis-objects"
require "awesome_print"

###
#
class Well < Base
  include Redis::Objects
  self.redis_prefix = self.to_s.downcase

  value :well_id,            ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :wsn,                ilk: :data, expiration: Utility::REDIS_EXPIRY
  value :proposed,           ilk: :data, expiration: Utility::REDIS_EXPIRY
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
  value :surface_point,      ilk: :data, expiration: Utility::REDIS_EXPIRY

  def self.id_fields
    [:project_id, :proposed, :wsn, :well_id]
  end

  def self.gen_id(doc)
    id_fields.map{ |x| doc[x] }.join(":")
  end

  def initialize(id)
    @id = id
  end

  Redis::Objects.redis = Utility.redis_pool
end
