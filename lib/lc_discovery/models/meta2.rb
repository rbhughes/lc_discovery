require 'elasticsearch/persistence'

class Meta

  attr_reader :attributes

  def initialize(attributes={})
    @attributes = attributes
  end

  def to_hash
    @attributes
  end

end



  #include Elasticsearch::Persistence::Model

  #index_name [Rails.application.engine_name, Rails.env].join('-')
  #index_name 'logicalcat-development'

  #analyzed_and_raw = { fields: {
  #  name: { type: 'string', analyzer: 'snowball' },
  #  raw:  { type: 'string', analyzer: 'keyword' }
  #} }

  #attribute :lc_id, String, mapping: { index: 'not_analyzed' }

  #attribute :project_server, String, mapping: analyzed_and_raw
  #attribute :project_server, String, mapping: { index: 'not_analyzed' }
  
  
  #attribute :name, String, mapping: analyzed_and_raw
  
  #attribute :suggest_name, String, default: {}, mapping: { type: 'completion', payloads: true }

  
  #attribute :profile
  
  #attribute :date, Date

  
  #attribute :members, String, default: [], mapping: analyzed_and_raw
  
  #attribute :members_combined, String, default: [], mapping: { analyzer: 'snowball' }
  
  #attribute :suggest_member, String, default: {}, mapping: { type: 'completion', payloads: true }

  
  #attribute :urls, String, default: []
  
  #attribute :album_count, Integer, default: 0

  
  #validates :name, presence: true

  #def albums
  #  Album.search(
  #    { query: {
  #        has_parent: {
  #          type: 'artist',
  #          query: {
  #            filtered: {
  #              filter: {
  #                ids: { values: [ self.id ] }
  #              }
  #            }
  #          }
  #        }
  #      },
  #      sort: 'released',
  #      size: 100
  #    },
  #    { type: 'album' }
  #)
  #end

  
  #def to_param
  
#  [id, name.parameterize].join('-')

#end



#class IndexManager
#  def self.create_index(options={})
#    client     = Meta.gateway.client
#    index_name = Meta.index_name
#
#    client.indices.delete index: index_name rescue nil if options[:force]
#
#    #settings = Artist.settings.to_hash.merge(Album.settings.to_hash)
#    #mappings = Artist.mappings.to_hash.merge(Album.mappings.to_hash)
#    settings = Meta.settings
#    mappings = Meta.mappings
#
#    client.indices.create index: index_name,
#      body: { settings: settings, mappings: mappings }
#      #body: { settings: settings.to_hash, mappings: mappings.to_hash }
#  end
#end



class MetaRepository
  include Elasticsearch::Persistence::Repository

  def initialize(options={})
    index  options[:index] || 'lc-devBROKEN'
    client Elasticsearch::Client.new url: options[:url], log: options[:log]
  end

  klass Meta

  settings number_of_shards: 1 do
    mapping do

      indexes :id, index: 'not_analyzed'
      indexes :project_server,  index: 'not_analyzed'
      indexes :project_home,    index: 'not_analyzed'
      indexes :project_path,    analyzer: 'standard' #check path hierarchy tokenizer
      indexes :project_name,    index: 'not_analyzed'
      indexes :schema_version,  index: 'not_analyzed'
      indexes :db_coordsys,     index: 'not_analyzed'
      indexes :map_coordsys,    index: 'not_analyzed'
      indexes :esri_coordsys,   index: 'not_analyzed' #maybe hierarchy
      indexes :unit_system,     index: 'not_analyzed'

      indexes :num_layers_maps, type: 'long'
      indexes :num_sv_interps,  type: 'long'
      indexes :num_wells,       type: 'long'
      indexes :num_vectors,     type: 'long'
      indexes :num_rasters,     type: 'long'
      indexes :num_formations,  type: 'long'
      indexes :num_zone_attr,   type: 'long'
      indexes :num_dir_surveys, type: 'long'

      indexes :oldest_file_mod, type: 'date'
      indexes :newest_file_mod, type: 'date'

      indexes :byte_size,       type: 'long'
      indexes :human_size,      index: 'not_analyzed'
      indexes :file_count,      type: 'long'

      indexes :min_longitude,   type: 'double'
      indexes :max_longitude,   type: 'double'
      indexes :min_latitude,    type: 'double'
      indexes :max_latitude,    type: 'double'

      indexes :activity_score,  type: 'long'

      #indexes :project_server,  analyzer: 'snowball'
      #indexes :project_server,  index: 'not_analyzed'
      #indexes :lc_id, index: 'not_analyzed'   # <-***
      #indexes :lc_id, analyzer: 'standard'   # <-***
      #indexes :num_files, index: 'not_analyzed', type: 'long'
      #indexes :blip, analyzer: 'standard'
      #indexes :hang, type: 'object'

    end
  end


  # Base64 encode the "image" field in the document
  #
  #def serialize(document)
  #  hash = document.to_hash.clone
  #  hash['image'] = Base64.encode64(hash['image']) if hash['image']
  #  hash.to_hash
  #end

  # Base64 decode the "image" field in the document
  #
  #def deserialize(document)
  #  hash = document['_source']
  #  hash['image'] = Base64.decode64(hash['image']) if hash['image']
  #  klass.new hash
  #end


end
