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


m = Meta.new(id: 'xxx', lc_id: 'aaaaa', project_server: 'OKC1GGX0002', num_files: 234)
ap '-'*30
ap m
ap '-'*30
#repository.save(m)
#repository.serialize(m)
repository.save(m)


#x = repository.find('xxx')
#puts x

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

z  repository.search(query: { wildcard: { project_server: 'OKC1GGX*' } }).first
ap z
#ap Meta.extract

=end



