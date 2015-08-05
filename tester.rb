require_relative 'lib/lc_discovery/extractors/meta_extractor'
require_relative 'lib/lc_discovery/models/meta'
require_relative 'lib/lc_discovery/repo'

require 'awesome_print'


#Meta.opts= {project: 'c:/programdata/geographix/projects/stratton', label: 'otter'}
#Meta.opts = {project: 'c:/programdata/geographix/projects/ks_harper', label: 'otter'}

#Meta.project = 'c:/programdata/geographix/projects/ks_harper'
#Meta.label = 'blahdy'











#behaves weirdly on some wifi
meta_repo = Repo.fetch('meta')
#meta_repo.index = 'lc-dev'
#meta_repo.client.transport.logger.formatter = proc { |s, d, p, m| "\e[2m# #{m}\n\e[0m" }
#meta_repo.create_index! force: true


puts "type==========#{meta_repo.type}"
puts "klass=========#{meta_repo.klass}"


extractor = MetaExtractor.new(
  project: 'c:/programdata/geographix/projects/ks_harper',
  label: 'boof'
)

m = extractor.extract
m["created_at"] = Time.now.utc.iso8601
m["updated_at"] = Time.now.utc.iso8601






#m = Meta.new(
#  id: 'xxx',
#  #lc_id: 'aaaaa',
#  project_server: 'OKC1GGX0002',
#  #blip: 'florida has some flowers',
#  #hang: {alpha: 'rotterdam', beta: 'the hague', gamma: 'amsterdam'},
#  num_files: 234
#)


ap '-'*30
ap m
ap '-'*30


meta_repo.save(m)
sleep 1

#r = repository.search(query: { match: { hang.beta: "hague" } })
#r = repository.search( "hague" )
#r = repository.search(query: { match: { 'hang.beta' => "hague" } })
#r = repository.search(query: { wildcard: { 'hang.beta' => "hag*" } })
#r = repository.search(query: { wildcard: { 'beta' => "hag*" } })
#r = repository.search(query: { match: { 'meta.hang.beta' => "hague" } })
r = meta_repo.search(query: { match: { 'num_files' => 234 } })
#r = repository.search( "hague" )

puts '---------------'
r.each_with_hit do |meta, hit|
  #puts "* #{meta.attributes[:lc_id]}, score: #{hit._score}"
  puts "* #{meta}, score: #{hit._score}"
end
puts '-------------'



