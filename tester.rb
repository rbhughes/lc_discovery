require_relative 'lib/lc_discovery/models/meta'
require_relative 'lib/lc_discovery/utility'

require 'awesome_print'

Utility.init_index('meta')

opts = {
  project: 'c:/programdata/geographix/projects/ks_harper',
  label: 'boof'
}

#returns an array
Meta.extract(opts).each do |x|
  Meta.create(x)
end

sleep 1


#a = Meta.all
#ap a

res = Meta.search query: {wildcard: {project_name: '*harper'}}

puts '-------------------------'
puts res.first.project_path

