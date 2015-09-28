require "elasticsearch/persistence/model"
require_relative "../lc_env"

class Meta
  include Elasticsearch::Persistence::Model

  self.gateway.client = Elasticsearch::Client.new url: LcEnv.elasticsearch_url

  index_name "discovery_metas"

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
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    ####################
    schema_version: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    db_coordsys: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    map_coordsys: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    esri_coordsys: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    unit_system: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    interpreters: {
      virtus_type: Array,
      es_mapping: es_s,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    num_layers_maps: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    num_sv_interps: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    num_wells: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    num_vectors: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    num_rasters: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    num_formations: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    num_zone_attr: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    num_dir_surveys: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    oldest_file_mod: {
      virtus_type: Date,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    newest_file_mod: {
      virtus_type: Date,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    byte_size: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    human_size: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    file_count: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    surface_bounds: {
      virtus_type: Hash,
      es_mapping: es_o,
      gxdb_view: nil,
      gxdb_table: nil,
      ppdm38: nil,
      ppdm39: nil
    },
    activity_score: {
      virtus_type: Integer,
      es_mapping: {},
      gxdb_view: nil,
      gxdb_table: nil,
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
    puts "after_save callback sez::::: Successfully saved: #{self}"
  end


  def gxdb_view(col)
    FIELDS[col.to_sym][:gxdb_view]
  end
  def gxdb_table(col)
    FIELDS[col.to_sym][:gxdb_table]
  end
  def ppdm38(col)
    FIELDS[col.to_sym][:ppdm38]
  end
  def ppdm39(col)
    FIELDS[col.to_sym][:ppdm39]
  end

  
  def self.native_columns
    exclude = [:created_at, :updated_at]
    self.new.attributes.except!(*exclude).keys.sort
  end

end
