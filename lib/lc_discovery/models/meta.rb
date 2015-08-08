require 'elasticsearch/persistence/model'

class Meta
  include Elasticsearch::Persistence::Model

  index_name 'metas'


  attribute :id,              String, mapping: { index: 'not_analyzed' }

  attribute :project_server,  String, mapping: { index: 'not_analyzed' }
  attribute :project_home,    String, mapping: { index: 'not_analyzed' }
  attribute :project_path,    String, mapping: { index: 'not_analyzed' } #ht
  attribute :project_name,    String, mapping: { index: 'not_analyzed' }
  attribute :schema_version,  String, mapping: { index: 'not_analyzed' }
  attribute :db_coordsys,     String, mapping: { index: 'not_analyzed' }
  attribute :map_coordsys,    String, mapping: { index: 'not_analyzed' }
  attribute :esri_coordsys,   String, mapping: { index: 'not_analyzed' } #ht
  attribute :unit_system,     String, mapping: { index: 'not_analyzed' }

  #ht hieararchy tokenizer

  attribute :num_layers_maps, Integer
  attribute :num_sv_interps,  Integer
  attribute :num_wells,       Integer
  attribute :num_vectors,     Integer
  attribute :num_rasters,     Integer
  attribute :num_formations,  Integer
  attribute :num_zone_attr,   Integer
  attribute :num_dir_surveys, Integer

  attribute :oldest_file_mod, Date
  attribute :newest_file_mod, Date

  attribute :byte_size,       Integer
  attribute :human_size,      String, mapping: { index: 'not_analyzed' }
  attribute :file_count,      Integer

  attribute :min_longitude,   Float
  attribute :max_longitude,   Float
  attribute :min_latitude,    Float
  attribute :max_latitude,    Float

  attribute :activity_score,  Integer

  after_save { puts "callback says Successfully saved: #{self}" }

  def self.extract(project, label)
    sleep 2
    [
      {
        id: 'yyy',
        project_server: "projserv_#{project}",
        project_path: "label=#{label}",
        num_vectors: 11,
        min_latitude: 11.1111
      },
      {
        id: 'zzz',
        project_server: "projserv_#{project}",
        project_path: "label=#{label}",
        num_vectors: 33,
        min_latitude: 13.331
      }
    ]
  end

end
