require "elasticsearch/persistence/model"
require_relative "../lc_env"

class Well
  include Elasticsearch::Persistence::Model

  self.gateway.client = Elasticsearch::Client.new url: LcEnv.elasticsearch_url

  index_name "discovery_wells"

  settings index: { 
    number_of_shards: 1,
    number_of_replicas: 0,

    analysis: {
      analyzer: {
        path_analyzer: {
          tokenizer: "path_tokens"
        }
      },
      tokenizer: {
        path_tokens: {
          type: "path_hierarchy",
          delimiter: "/"
        }
      }
    }
  }

  es_na = { mapping: { index: "not_analyzed" }}
  es_pa = { mapping: { analyzer: "path_analyzer" }}
  es_s  = { mapping: { type: "string" }}
  es_o  = { mapping: { type: "object" }}

  FIELDS = {
    id: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    label: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    ##### base_doc #####
    project_home: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    project_host: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    project_id: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    project_name: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    project_path: {
      virtus_type: String,
      es_mapping: es_pa,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    ####################
    well_id: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Well Id]",
      gxdb_table: "WELL.UWI",
      ppdm38: nil,
      ppdm39: nil
    },
    source: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Source]",
      gxdb_table: "WELL.PRIMARY_SOURCE",
      ppdm38: nil,
      ppdm39: nil
    },
    operator: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Operator]",
      gxdb_table: "WELL.OPERATOR",
      ppdm38: nil,
      ppdm39: nil
    },
    state: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[State]",
      gxdb_table: "WELL.PROVINCE_STATE",
      ppdm38: nil,
      ppdm39: nil
    },
    county: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[County]",
      gxdb_table: "WELL.COUNTY",
      ppdm38: nil,
      ppdm39: nil
    },
    country: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Country]",
      gxdb_table: "WELL.COUNTRY",
      ppdm38: nil,
      ppdm39: nil
    },
    well_name: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Well Name]",
      gxdb_table: "WELL.WELL_NAME",
      ppdm38: nil,
      ppdm39: nil
    },
    well_number: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Well Number]",
      gxdb_table: "WELL.WELL_NUMBER",
      ppdm38: nil,
      ppdm39: nil
    },
    common_well_name: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Common Well Name]",
      gxdb_table: "WELL.COMMON_WELL_NAME",
      ppdm38: nil,
      ppdm39: nil
    },
    latitude: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Surface Latitude]",
      gxdb_table: "WELL.SURFACE_LATITUDE",
      ppdm38: nil,
      ppdm39: nil
    },
    longitude: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Surface Longitude]",
      gxdb_table: "WELL.SURFACE_LONGITUDE",
      ppdm38: nil,
      ppdm39: nil
    },
    lat: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Lat]",
      gxdb_table: "WELL.SURFACE_LATITUDE",
      ppdm38: nil,
      ppdm39: nil
    },
    lng: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Lng]",
      gxdb_table: "WELL.SURFACE_LONGITUDE",
      ppdm38: nil,
      ppdm39: nil
    },
    status: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Status]",
      gxdb_table: "WELL.CURRENT_STATUS",
      ppdm38: nil,
      ppdm39: nil
    },
    classification: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Classification]",
      gxdb_table: "WELL.CURRENT_CLASS",
      ppdm38: nil,
      ppdm39: nil
    },
    datum_elev: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Datum Elev]",
      gxdb_table: "WELL.DEPTH_DATUM_ELEV",
      ppdm38: nil,
      ppdm39: nil
    },
    ground_elev: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Ground Elev]",
      gxdb_table: "WELL.GROUND_ELEV",
      ppdm38: nil,
      ppdm39: nil
    },
    plugback_depth: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Plugback Depth]",
      gxdb_table: "WELL.PLUGBACK_DEPTH",
      ppdm38: nil,
      ppdm39: nil
    },
    td: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[TD]",
      gxdb_table: "WELL.FINAL_TD",
      ppdm38: nil,
      ppdm39: nil
    },
    fm_at_td: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Fm at TD]",
      gxdb_table: "WELL.TD_FORM",
      ppdm38: nil,
      ppdm39: nil
    },
    fm_alias_at_td: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Fm Alias at TD]",
      gxdb_table: "WELL.GX_TD_FORM_ALIAS",
      ppdm38: nil,
      ppdm39: nil
    },
    spud_date: {
      virtus_type: Date,
      es_mapping: {},
      gxdb_view: "WellHeader.[Spud Date]",
      gxdb_table: "WELL.SPUD_DATE",
      ppdm38: nil,
      ppdm39: nil
    },
    comp_date: {
      virtus_type: Date,
      es_mapping: {},
      gxdb_view: "WellHeader.[Comp Date]",
      gxdb_table: "WELL.COMPLETION_DATE",
      ppdm38: nil,
      ppdm39: nil
    },
    data_date: {
      virtus_type: Date,
      es_mapping: {},
      gxdb_view: "WellHeader.[Data Date]",
      gxdb_table: "WELL.ROW_CHANGED_DATE",
      ppdm38: nil,
      ppdm39: nil
    },

    area: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Area]",
      gxdb_table: "WELL.GEOLOGIC_PROVINCE",
      ppdm38: nil,
      ppdm39: nil
    },
    district: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[District]",
      gxdb_table: "WELL.DISTRICT",
      ppdm38: nil,
      ppdm39: nil
    },
    field: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Field]",
      gxdb_table: "WELL.ASSIGNED_FIELD",
      ppdm38: nil,
      ppdm39: nil
    },
    permit_number: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Permit Number]",
      gxdb_table: "WELL.WELL_GOVT_ID",
      ppdm38: nil,
      ppdm39: nil
    },
    datum_type: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Datum Type]",
      gxdb_table: "WELL.DEPTH_DATUM",
      ppdm38: nil,
      ppdm39: nil
    },
    alternate_id: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Alternate Id]",
      gxdb_table: "WELL.GX_ALTERNATE_ID",
      ppdm38: nil,
      ppdm39: nil
    },
    old_id: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Old ID]",
      gxdb_table: "WELL.GX_OLD_ID",
      ppdm38: nil,
      ppdm39: nil
    },
    user_1: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[User 1]",
      gxdb_table: "WELL.GX_USER1",
      ppdm38: nil,
      ppdm39: nil
    },
    user_2: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[User 2]",
      gxdb_table: "WELL.GX_USER2",
      ppdm38: nil,
      ppdm39: nil
    },
    lease_name: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Lease Name]",
      gxdb_table: "WELL.LEASE_NAME",
      ppdm38: nil,
      ppdm39: nil
    },
    platform_id: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Platform ID]",
      gxdb_table: "WELL.PLATFORM_ID",
      ppdm38: nil,
      ppdm39: nil
    },
    water_depth: {
      virtus_type: Float,
      es_mapping: {},
      gxdb_view: "WellHeader.[Water Depth]",
      gxdb_table: "WELL.WATER_DEPTH",
      ppdm38: nil,
      ppdm39: nil
    },
    water_datum: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Water Datum]",
      gxdb_table: "WELL.WATER_DATUM",
      ppdm38: nil,
      ppdm39: nil
    },
    parent_uwi_type: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Parent UWI Type]",
      gxdb_table: "WELL.PARENT_RELATIONSHIP_TYPE",
      ppdm38: nil,
      ppdm39: nil
    },
    permit_date: {
      virtus_type: Date,
      es_mapping: {},
      gxdb_view: "WellHeader.[Permit Date]",
      gxdb_table: "WELL.GX_PERMIT_DATE",
      ppdm38: nil,
      ppdm39: nil
    },
    user_date: {
      virtus_type: Date,
      es_mapping: {},
      gxdb_view: "WellHeader.[User Date]",
      gxdb_table: "WELL.GX_USER_DATE",
      ppdm38: nil,
      ppdm39: nil
    },
    parent_uwi: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Parent UWI]",
      gxdb_table: "WELL.PARENT_UWI",
      ppdm38: nil,
      ppdm39: nil
    },
    legal_survey_type: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Legal Survey Type]",
      gxdb_table: "WELL.LEGAL_SURVEY_TYPE",
      ppdm38: nil,
      ppdm39: nil
    },
    location: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Location]",
      gxdb_table: "WELL.GX_LOCATION_STRING",
      ppdm38: nil,
      ppdm39: nil
    },
    percent_allocation: {
      virtus_type: Float,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Percent Allocation]",
      gxdb_table: "WELL.GX_PERCENT_ALLOCATION",
      ppdm38: nil,
      ppdm39: nil
    },
    location: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Location]",
      gxdb_table: "WELL.GX_LOCATION_STRING",
      ppdm38: nil,
      ppdm39: nil
    },
    row_changed_date: {
      virtus_type: Date,
      es_mapping: {},
      gxdb_view: "WellHeader.[Row Changed Date]",
      gxdb_table: "WELL.ROW_CHANGED_DATE",
      ppdm38: nil,
      ppdm39: nil
    },
    original_operator: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Original Operator]",
      gxdb_table: "WELL.ORIGINAL_OPERATOR",
      ppdm38: nil,
      ppdm39: nil
    },
    internal_status: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Internal Status]",
      gxdb_table: "WELL.GGX_INTERNAL_STATUS",
      ppdm38: nil,
      ppdm39: nil
    },
    wsn: {
      virtus_type: Integer,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[WSN]",
      gxdb_table: "WELL.GX_WSN",
      ppdm38: nil,
      ppdm39: nil
    },
    surface_point: {
      virtus_type: Hash,
      es_mapping: es_o,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    proposed: {
      virtus_type: Boolean,
      es_mapping: es_na,
      gxdb_view: "WellHeader.[Proposed]",
      gxdb_table: "WELL.GX_PROPOSED_FLAG",
      ppdm38: nil,
      ppdm39: nil
    }

  }


  FIELDS.each_pair do |column, v|
    attribute column, v[:virtus_type], v[:es_mapping].dup #gotta dup!
  end


  validates :id, presence: true
  validates :label, presence: true

  after_create do
    puts self.errors.inspect if self.errors
  end


  after_save do
    #puts "after_save callback sez::::: Successfully saved: #{self}"
  end

  def gxdb_view(col)
    FIELDS[col.to_sym][:gxdb_view]
  end
  def gxdb_table(col)
    FIELDS[col.to_sym][:gxdb_table]
  end
  def ppdm38_for(col)
    FIELDS[col.to_sym][:ppdm38]
  end
  def ppdm39_for(col)
    FIELDS[col.to_sym][:ppdm39]
  end


  def self.native_columns
    exclude = [:created_at, :updated_at]
    self.new.attributes.except!(*exclude).keys.sort
  end


end
