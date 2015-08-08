require_relative 'lib/lc_discovery/models/meta'
require_relative 'lib/lc_discovery/utility'
require 'awesome_print'

#Well.gateway.client = Elasticsearch::Client.new host: 'localhost:9200', log: true


Utility.init_index('meta')


Meta.extract('stratton', 'purple').each do |x|
  Meta.create(x)
end
#ap "Valid? #{well.valid?}"

#well.test
#well.save


sleep 1



a = Meta.all
ap a



#well.save

