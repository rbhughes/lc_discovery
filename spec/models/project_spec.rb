require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../../lib/lc_discovery/models/project"
require_relative "../../lib/lc_discovery/utility"
require 'date'

require "awesome_print"

describe Project do

  before do 

    @doc_a = {
      :label => "fakery",
      :project_id => "fakery:spinoza:c_dev_lc_discovery_spec_support_sample",
      :project_path => "c:/dev/lc_discovery/spec/support/sample",
      :project_name => "sample",
      :project_home => "support",
      :project_host => "spinoza",
      :interpreters => ["bonnie", "clyde", 345.444],
      :schema_version => 123,
      :db_coordsys => "C1 Geographic Latitude/Longitude10 12 Longitude LatitudeY 03COORDINATE SYSTEMS\\World\\North America\\United States",
      :map_coordsys => "C1 SPCS27 - Texas South30 4 4205 Texas South Easting NorthingY293COORDINATE SYSTEMS\\World\\North America\\United States\\State Plane 1927",
      :esri_coordsys => "PROJCS[\"SPCS27 - Texas South\",GEOGCS[\"GCS_North_American_1927\",DATUM[\"D_North_American_1927\",SPHEROID[\"Clarke_1866\",6378206.4,294.9786982]],PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199432955]],PROJECTION[\"Lambert_Conformal_Conic\"],PARAMETER[\"Central_Meridian\",-98.500000],PARAMETER[\"Latitude_Of_Origin\",25.666667],PARAMETER[\"Scale_Factor\",1.000000],PARAMETER[\"Standard_Parallel_1\",27.833333],PARAMETER[\"Standard_Parallel_2\",26.166667],PARAMETER[\"False_Northing\",0.000000],PARAMETER[\"False_Easting\",2000000.000000],UNIT[\"U.S. Survey Feet\",0.304801]]",
      :unit_system => "English",
      :num_layers_maps => 8,
      :num_sv_interps => 3,
      :oldest_file_mod => 1446591771,
      :newest_file_mod => 1446593771,
      :byte_size => 25321472,
      :human_size => "24.15 MB",
      :file_count => 3,
      :num_wells => 5,
      :num_vectors => "3", # <--hey look, a string
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

    @doc_b = @doc_a.merge({
      label:"boom", 
      project_id: "boom:spinoza:c_dev_lc_discovery_spec_support_sample",
    })

    @lc_id_a = Project.lc_id(@doc_a)
    @lc_id_b = Project.lc_id(@doc_b)

  end





  describe "something unique to Project objects here" do


  end





end
