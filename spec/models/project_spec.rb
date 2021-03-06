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
    Redis::Objects.redis.select 1 

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

    @id_a = Project.gen_id(@doc_a)
    @id_b = Project.gen_id(@doc_b)

    @project_a = Project.new(@id_a)
    @project_a.populate(@doc_a)

    @project_b = Project.new(@id_b)
    @project_b.populate(@doc_b)

  end

  after do
    @project_a.delete
    @project_b.delete
    ap "!"*1000 unless (Project.redis.keys "project*").empty?
  end


  describe "when creating, deleting and finding Project objects" do

    it "Project gets created and stored in Redis" do
      Project.exists?(@project_a).must_equal(true)
    end

    it "Project descends from Base but has child key prefix" do
      @project_a.class.superclass.name.must_equal("Base")
      @project_a.redis.keys("project:*:lc_id").wont_be_empty
    end

    # just compares strings for now
    it "#populate loads expected document attributes" do
      @project_a.all_redis_objects.each do |o|
        field = o[0]
        next if [:lc_id].include?(field)
        redis_type = o[1][:type] 
        case redis_type
        when :value
          @project_a.method(field).call.get.to_s.must_equal(@doc_a[field].to_s)
        when :set
          @project_a.method(field).call.get.sort.must_equal(
            @doc_a[field].map(&:to_s).sort
          )
        end
      end
    end

    it "#find and #find_by work as expected" do
      results = Project.find([@project_a, @id_b, "nonsense", @doc_a])
      results.size.must_equal(2)
      results[0].must_be_instance_of(Project)
      results[1].must_be_instance_of(Project)
      results[0].to_hash.wont_equal(results[1].to_hash)
      args = {
        label: @doc_b[:label],
      }
      results = Project.find_by(args)
      results.size.must_equal(1)
      results[0].to_hash.must_equal(@project_b.to_hash)
    end

    it "#delete works as expected" do
      Project.exists?(@project_a).must_equal(true)
      Project.exists?(@project_b).must_equal(true)
      count = Project.delete([@project_a, "nonsense"])
      count.must_equal(1)
      Project.exists?(@project_a).must_equal(false)
      Project.exists?(@project_b).must_equal(true)
      @project_b.delete
      Project.exists?(@project_b).must_equal(false)
    end

  end


  describe "when checking a Project object's Redis fields" do

    it "has a proper Redis instance defined" do
      @project_a.redis.to_s.must_match(/Redis::Objects/)
    end

    it "a Project object has expected fields defined" do
      all_fields = Project.all_redis_objects.keys
      count = all_fields.size
      all_fields.each do |f|
        @project_a.all_redis_objects.keys.must_include(f)
        @project_a.redis.exists(@project_a.redis_field_key(f)).must_equal(true)
        count -= 1
      end
      count.must_equal(0)
    end

  end


  #describe "when doing something more specific" do
  #end

end
