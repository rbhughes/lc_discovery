require "./lib/lc_discovery/utility"

require "digest"

# <model>:<label>:<




proj = "c:\\programdata\\geographix\\projects\\stratton"
label = "my laB 123__4 cursdd   el \dux??*"

#----------
# When combined with redis-objects, the resultant key looks like:
# <model>:<label>:<host>:<proj>:<field>
# well:east texas:okc1ggx0001:c_programdata_geographix_projects_stratton:uwi
# * everything is downcased, spaces are allowed in label
def clean_redis_key(proj, label)
  host = Discovery.parse_host(proj)
  path = proj.gsub(/\\|\/|:/, "_").chomp.strip.squeeze("_").gsub(/^_|_$/,"")
  "#{label}:#{host}:#{path}".downcase
end


puts sep_to_underscore("c:\\my path\\to\\stuff")
puts sep_to_underscore("__\\x:/another/path")
puts sep_to_underscore("\\\\server\\shaDDDDDre\\another/path")


def hashy(s)
  puts "md5:  #{Digest::MD5.hexdigest(s)}"
  puts "sha1: #{Digest::SHA1.hexdigest(s)}"
  puts "sha2: #{Digest::SHA2.hexdigest(s)}"
end

puts hashy("asdf")

#Utility.clean_key(proj, label)

