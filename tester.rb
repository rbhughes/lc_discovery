require_relative "lib/lc_discovery/ex_meta"
require 'awesome_print'

require_relative "es_models/meta"


#Meta.set_opts({gxdb: 'asfd', proj: 'blalh'})
#puts m.process_projects



#Meta.opts= {project: 'c:/programdata/geographix/projects/stratton', label: 'otter'}
#Meta.opts = {project: 'c:/programdata/geographix/projects/ks_harper', label: 'otter'}

#Meta.project = 'c:/programdata/geographix/projects/ks_harper'
#Meta.label = 'blahdy'


extractor = ExMeta.new(
  project: 'c:/programdata/geographix/projects/ks_harper',
  label: 'boof'
)

#ap extractor.extract
#IndexManager.create_index(force: true)





repository = MetaRepository.new url: 'http://localhost:9200', log: true

# Configure the repository instance
repository.index = 'logicalcat-development'
repository.client.transport.logger.formatter = proc { |s, d, p, m| "\e[2m# #{m}\n\e[0m" }

repository.create_index! force: true

puts "type==========#{repository.type}"
puts "klass=========#{repository.klass}"
ap repository.mappings

#m = Meta.new(id: 'xxx', lc_id: 'aaaaa', project_server: 'OKC1GGX0002', num_files: 234)
m = Meta.new(
  id: 'xxx',
  lc_id: 'aaaaa',
  project_server: 'OKC1GGX0002',
  blip: 'florida has some flowers',
  hang: {alpha: 'rotterdam', beta: 'the hague', gamma: 'amsterdam'},
  num_files: 234
)


ap '-'*30
ap m
ap '-'*30


#repository.save(m)
#repository.serialize(m)
repository.save(m)
sleep 1

#r = repository.search(query: { match: { hang.beta: "hague" } })
r = repository.search( "hague" )
#r = repository.search(query: { match: { 'hang.beta' => "hague" } })
#r = repository.search(query: { wildcard: { 'hang.beta' => "hag*" } })
#r = repository.search(query: { wildcard: { 'beta' => "hag*" } })
#r = repository.search(query: { match: { 'meta.hang.beta' => "hague" } })
#r = repository.search( "hague" )
puts '---------------'
#r = repository.search(query: { match: { blip: "florida" } })
#puts '---------------'
#r = repository.search(query: { term: { lc_id: "aaaaa" } }).first

#r = repository.search(query: { wildcard: { project_server: 'OKC1GGX*' } }).first
#r = repository.search(query: { match: { blip: 'florida' } }).first
#ap Meta.extract

#x = repository.find('xxx')
#puts x


r.each_with_hit do |meta, hit|
  #puts "* #{meta.attributes[:lc_id]}, score: #{hit._score}"
  puts "* #{meta}, score: #{hit._score}"
end



#puts '-------------'

#y = repository.search('aaaaa').first
#puts y

#puts '-------------'
#z = repository.search
#puts z


=begin
Meta.create(id: 'xxx', lc_id: 'aaaaa', project_server: 'OKC1GGX0002')


x = Meta.search 'OKC1GGX0002' 
ap x.results
puts '-------------'

y = Meta.find('xxx')
ap y
puts '..............'


=end



