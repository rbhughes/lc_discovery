require_relative "lib/lc_discovery/meta"
require 'awesome_print'


#Meta.set_opts({gxdb: 'asfd', proj: 'blalh'})
#puts m.process_projects



#Meta.opts= {project: 'c:/programdata/geographix/projects/stratton', label: 'otter'}
#Meta.opts = {project: 'c:/programdata/geographix/projects/ks_harper', label: 'otter'}

#Meta.project = 'c:/programdata/geographix/projects/ks_harper'
#Meta.label = 'blahdy'


extractor = Meta.new(
  project: 'c:/programdata/geographix/projects/ks_harper',
  label: 'boof'
)

ap extractor.extract

#ap Meta.extract

