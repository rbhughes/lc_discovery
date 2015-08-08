require 'elasticsearch/persistence/model'

class Well
  include Elasticsearch::Persistence::Model

  index_name 'wells'

  #attribute :id, String
  attribute :well_government_id, String
  attribute :uwi, String, mapping: { index: 'not_analyzed' }
  attribute :surface_latitude, Float #, mapping: {type: 'double'}
  attribute :surface_longitude, Float #, mapping: {type: 'double'}

  # Define a plain `title` attribute
  #
  #attribute :title,  String

  # Define an `author` attribute, with multiple analyzers for this field
  #
  #attribute :author, String, mapping: { fields: {
  #                             author: { type: 'string'},
  #                             raw:    { type: 'string', analyzer: 'keyword' }
  #                           } }


  # Define a `views` attribute, with default value
  #
  #attribute :views,  Integer, default: 0, mapping: { type: 'integer' }

  # Validate the presence of the `title` attribute
  #
  #validates :title, presence: true

  # Execute code after saving the model.
  #
  after_save { puts "callback says Successfully saved: #{self}" }


  #extract attributes
  def self.xtra(project, label)
    sleep 2
    [
      {
        id: 'yyy',
        uwi: "uwi_#{project}",
        surface_latitude: 11.44,
        well_government_id: "WGI_#{label}"
      },
      {
        id: 'zzz',
        uwi: "uwi_#{project}",
        surface_latitude: 55.44,
        well_government_id: "WGI_#{label}"
      }
    ]
  end

  #this would set an instance var if needed
  def test
    self.surface_longitude = 333.33
  end


  #where to put this?
  def self.init_index(options={})
    client = self.gateway.client
    index_name = self.index_name

    begin
      client.indices.delete index: index_name #rescue nil if options[:force]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      puts "No prior index found. Creating #{index_name}"

    rescue Exception => x 
      puts x.message
      puts x.backtrace.inspect
    end

      client.indices.create index: index_name,
        body: {settings: self.settings.to_hash, mappings: self.mappings.to_hash }

  end
end
