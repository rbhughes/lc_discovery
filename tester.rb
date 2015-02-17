require_relative "lib/lc_discovery/extracts"




puts Extracts.list_types

a = [0,1,4]

puts Extracts.sum_extracts a


puts "----------------"
puts Extracts.assigned_extracts 19


=begin
a = "c:\\drive\\thing space\\thing"
b = "\\\\server\\share space\\path"
c = "//server/sher/th aig"


#
if ( /^\/\/.*|[a-z]:.*/i =~ c )
  puts "MATCH"
end
require "yaml"

cfg = {

  elasticsearch: {
    host: "localhost",
    port: 9200
  },

  homes: [
    { 
      path: "//server/home_a", 
      active: true,
      scan_date: Time.now,
      scan_deep: false,
      projects: [
        { path: "//server/home_a/proj_one", active: true },
        { path: "//server/home_a/proj_two", active: true },
        { path: "//server/home_a/proj_three", active: true },
        { path: "//server/home_a/proj_four", active: true }
      ]
    },
    { 
      path: "//server/home_b", 
      active: true,
      scan_date: Time.now,
      scan_deep: false,
      projects: []
    },
    { 
      path: "//server/home_c", 
      active: true,
      scan_date: Time.now,
      scan_deep: false,
      projects: []
    },
    { 
      path: "//server/home_d", 
      active: false,
      scan_date: Time.now,
      scan_deep: false,
      projects: []
    }
  ]






}


path = "c:/dev/lc_discovery/config.yml"
#puts cfg.to_yaml

File.open(path,'w') do |h| 
   h.write cfg.to_yaml
end

y = YAML.load_file(path)

#puts "\n    active?  path\n    -------  ----"
#y[:homes].each_with_index do |home, i|
#  printf("%-4d %-7s %s\n", i, home[:active], home[:path])
#end
require "awesome_print"

test = "//server/home_b"
#sel = y[:homes].select{ |h| h[:path].casecmp(test)==0 }.first[:path]
sel = y[:homes].select{ |h| h[:path].casecmp(test)==0 }.first

sel[:path] = "XXXXXXXXXX"
puts "---------------"
puts y




=end
