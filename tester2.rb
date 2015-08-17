#require 'awesome_print'
#
#require_relative 'lib/lc_discovery/extractors/well_extractor'
#require_relative 'lib/lc_discovery/models/well'
require_relative 'lib/lc_discovery/utility'


Utility.init_index('well')

=begin
opts1 = {
  project: 'c:/programdata/geographix/projects/ks_harper',
  label: 'boof'
}
opts2 = {
  project: 'c:/programdata/geographix/projects/stratton',
  label: 'boof'
}


jobs = WellExtractor.parcels(opts2[:project], 5)
jobs.each do |job|
  puts "WellWorker.perform_async(#{job[:batch]}, #{job[:mark]})"
end

=end

#returns an array
#[opts1, opts2].each do |o|
#[opts2].each do |o|
  #a = WellExtractor.new(o).extract(5, 10)
  #b = WellExtractor.new(o).extract(5, 1)


  #a = WellExtractor.new(o).cloven
  #a.each do |x|
  #  ap x
  #  #Meta.create(x)
  #end
#end





#sleep 1


#a = Meta.all
#ap a

#res = Meta.search query: {wildcard: {project_name: '*harper'}}

#puts res.first

