require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../../lib/lc_discovery/models/meta"
require_relative "../../lib/lc_discovery/utility"

require "awesome_print"
#require 'connection_pool'


describe Meta do

  before do 

    @obj = {
      :label => "fakery",
      :project_id => "a031e828b57f6a890ca35f8bd26aa02924a1e963",
      :project_path => "c:/dev/lc_discovery/spec/support/sample",
      :project_name => "sample",
      :project_home => "support",
      :project_host => "spinoza",
      :id => "a031e828b57f6a890ca35f8bd26aa02924a1e963",
      :interpreters => ["bonnie", "clyde", 345.444],
      :schema_version => 123,
      :db_coordsys => "C1 Geographic Latitude/Longitude10 12 Longitude LatitudeY 03COORDINATE SYSTEMS\\World\\North America\\United States",
      :map_coordsys => "C1 SPCS27 - Texas South30 4 4205 Texas South Easting NorthingY293COORDINATE SYSTEMS\\World\\North America\\United States\\State Plane 1927",
      :esri_coordsys => "PROJCS[\"SPCS27 - Texas South\",GEOGCS[\"GCS_North_American_1927\",DATUM[\"D_North_American_1927\",SPHEROID[\"Clarke_1866\",6378206.4,294.9786982]],PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199432955]],PROJECTION[\"Lambert_Conformal_Conic\"],PARAMETER[\"Central_Meridian\",-98.500000],PARAMETER[\"Latitude_Of_Origin\",25.666667],PARAMETER[\"Scale_Factor\",1.000000],PARAMETER[\"Standard_Parallel_1\",27.833333],PARAMETER[\"Standard_Parallel_2\",26.166667],PARAMETER[\"False_Northing\",0.000000],PARAMETER[\"False_Easting\",2000000.000000],UNIT[\"U.S. Survey Feet\",0.304801]]",
      :unit_system => "English",
      :num_layers_maps => 8,
      :num_sv_interps => 3,
      :oldest_file_mod => "2015-09-18T18:43:41Z",
      :newest_file_mod => "2015-11-02T03:43:05Z",
      :byte_size => 25321472,
      :human_size => "24.15 MB",
      :file_count => 3,
      :num_wells => 5,
      :num_vectors => 3,
      :num_rasters => 1,
      :num_formations => 4,
      :num_zone_attr => 4,
      :num_dir_surveys => 3,
      :surface_bounds => {
        :name => "surface_bounds",
        :location => {
          :type => "polygon",
          :coordinates => [
            [
              [-122.2, 37.4],
              [-122.2, 37.6],
              [-122.0, 37.6],
              [-122.0, 37.4],
              [-122.2, 37.4]
            ]
          ]
        }
      },
      :activity_score => 62
    }
  end

  describe "initialization" do

    it "does things" do
      meta = Meta.new(@obj)

      puts "--------"
      ap meta.to_hash
      puts "--------"
    end


  end

end
