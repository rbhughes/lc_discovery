require 'awesome_print'

require_relative 'lib/lc_discovery/extractors/meta_extractor'
require_relative 'lib/lc_discovery/models/meta'
#require_relative 'lib/lc_discovery/extractors/well_extractor'
#require_relative 'lib/lc_discovery/models/well'
require_relative 'lib/lc_discovery/utility'


Utility.init_index('meta')

opts1 = {
  project: 'c:/programdata/geographix/projects/ks_harper',
  label: 'boof'
}
opts2 = {
  project: 'c:/programdata/geographix/projects/stratton',
  label: 'boof'
}



#returns an array
[opts1, opts2].each do |o|
  a = MetaExtractor.new(o).extract
  a.each do |x|
    Meta.create(x)
  end
end





sleep 1


#a = Meta.all
#ap a

#res = Meta.search query: {wildcard: {project_name: '*harper'}}

#puts res.first

