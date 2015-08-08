require_relative 'lib/lc_discovery/models/well'
require 'awesome_print'

#Well.gateway.client = Elasticsearch::Client.new host: 'localhost:9200', log: true


Well.init_index(force: true)

#well = Well.new( id: 'xxx', uwi: 'asdfasdf', surface_latitude: 111.111)


#ap well

#well = Well.new Well.xtra('stratton', 'purple')
Well.xtra('stratton', 'purple').each do |w|
  Well.create(w)
end
#ap "Valid? #{well.valid?}"

#well.test
#well.save


sleep 1



a = Well.all
ap a



#well.save



