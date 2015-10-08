require "elasticsearch/persistence/model"
require_relative "../lc_env"

class TestDoc
  include Elasticsearch::Persistence::Model

  self.gateway.client = Elasticsearch::Client.new url: LcEnv.elasticsearch_url

  index_name "discovery_test_docs"

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
    test_thing: {
      virtus_type: String,
      es_mapping: es_na,
      gxdb_view: "test_gxdb_view",
      gxdb_table: "test_gxdb_table",
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
    puts self.errors.inspect unless self.errors.messages.empty?
  end


  after_save do
    #puts "after_save callback sez::::: Successfully saved: #{self.id}"
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

