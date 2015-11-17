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


  describe "when creating and deleting a single Project object" do

    it "#lc_id generates the expected key string" do
      expected = "fakery:spinoza:c_dev_lc_discovery_spec_support_sample"
      Project.lc_id(@doc_a).must_equal(expected)
    end


    it "#new should create the lc_id field that captures the id" do
      proj = Project.new(@lc_id_a)
      proj.lc_id.get.must_equal(@lc_id_a)
      proj.id.must_equal(@lc_id_a)
      proj.delete
    end


    it "#exists? should check if a Project exists for string, object or hash" do
      as_string = Project.lc_id(@doc_a)
      as_proj = Project.new(as_string)
      as_hash = @doc_a

      as_string.must_be_instance_of(String)
      as_proj.must_be_instance_of(Project)
      as_hash.must_be_instance_of(Hash)

      Project.exists?(as_string).must_equal(true)
      Project.exists?(as_proj).must_equal(true)
      Project.exists?(as_hash).must_equal(true)

      Project.exists?("bogus").must_equal(false)
      Project.exists?(Object.new).must_equal(false)
      Project.exists?({boom:"slang"}).must_equal(false)

      as_proj.delete
    end


    #just compares strings. lc_id won't exist and surface_bounds is not done
    it "#populate loads expected document attributes" do
      proj = Project.new(@lc_id_a)
      proj.populate(@doc_a)
      proj.redis_objects.each do |o|
        field = o[0]
        next if [:lc_id, :surface_bounds].include?(field)
        redis_type = o[1][:type] 
        case redis_type
        when :value
          proj.method(field).call.value.to_s.must_equal(@doc_a[field].to_s)
        when :set
          proj.method(field).call.members.sort.must_equal(
            @doc_a[:interpreters].map(&:to_s).sort
          )
        end
      end
      proj.delete
    end


    # note, the redis-objects are still defined because the object reference is
    # not nil yet, but no keys exist in redis--it really did get deleted.
    it "#delete should delete the Project object and all of its fields" do
      proj = Project.new(@lc_id_a)
      proj.populate(@doc_a)
      Project.exists?(proj).must_equal(true)
      proj.delete
      Project.exists?(proj).must_equal(false)
      proj.redis_objects.each do |o|
        field = o[0]
        redis_type = o[1][:type] 
        case redis_type
        when :value
          proj.method(field).call.value.must_be_nil
        when :set
          proj.method(field).call.members.must_be_empty
        end
      end
    end
  

    it "#delete should only affect the Project on which it is called" do
      proj_a = Project.new(@lc_id_a)
      proj_a.populate(@doc_a)

      proj_b = Project.new(@lc_id_b)
      proj_b.populate(@doc_b)

      Project.exists?(proj_a).must_equal(true)
      Project.exists?(proj_b).must_equal(true)

      proj_a.delete
      Project.exists?(proj_a).must_equal(false)
      Project.exists?(proj_b).must_equal(true)
      proj_b.delete
    end

  end




  describe "when finding Project objects" do

    it "Project#find returns nil if lc_id string is not found" do
      results = Project.find("nope")
      results.must_be_empty
    end

    it "Project#find with lc_id string returns single (populated) Project" do
      proj = Project.new(@lc_id_a)
      proj.populate(@doc_a)
      results = Project.find(@lc_id_a)
      results.size.must_equal(1)
      found = results[0]
      found = Project.find(@lc_id_a)[0]
      found.id.must_equal(@lc_id_a)
      found.label.get.must_equal(@doc_a[:label])
      found.project_id.get.must_equal(@doc_a[:project_id])
      found.delete
    end

    it "Project#find with array of lc_id strings returns multiple Projects" do 
      proj_a = Project.new(@lc_id_a)
      proj_a.populate(@doc_a)
      proj_b = Project.new(@lc_id_b)
      proj_b.populate(@doc_b)

      results = Project.find(["aaa","bbb","ccc"])
      #results = Project.find([@lc_id_a, @lc_id_b, "non-existent_lc_id"])
      #ap results

      
      proj_a.delete
      proj_b.delete
    end


    it "#find returns sets of Project objects based on attributes supplied" do
      skip

      @proj = Project.new(@lc_id_a)
      @proj.populate(@doc_a)

      ap @proj.project_id.get
      #sooo... the idea is that the keys correspond to fields in the redis key
      #and any values (if their keys match known keys) will be added to the 
      #matcher string
      args = {
        project_id: "sssssssssssssss",
        label: "fakery",
        well_id: "321452345",
        project_host: "spinoza"
      }
      x = Project.find(args)
      ap x


      #ap "_______________"*40
      #@proj = Project.new(@test_id)
      #@proj.populate(@doc)
      #cursor = 0
      #all_keys   = []
      #loop {
      #  cursor, keys = @proj.redis.scan cursor, :match => "project:*:pro*"
      #  all_keys += keys
      #  break if cursor == "0"
      #}
      #ap all_keys
      #ap "_______________"*40
      @proj.purge
    end

  end


  describe "when checking a Project object's Redis fields" do

    it "has a proper Redis instance defined" do
      skip
      @proj = Project.new(@lc_id_a)
      @proj.redis.to_s.must_match(/Redis::Objects/)
      @proj.purge
    end


    it "a proj object has expected fields defined" do
      skip
      @proj = Project.new(@lc_id_a)
      fields = Project.field_names
      count = fields.size

      fields.each do |f|
        @proj.redis_objects.keys.must_include(f)
        @proj.redis.exists(@proj.redis_field_key(f)).must_equal(false)
        count -= 1
      end
      count.must_equal(0)
      @proj.purge
    end


    it "#populate adds attributes that are found by redis exists" do
      skip
      @proj = Project.new(@lc_id_a)
      @proj.populate(@doc_a)
      Project.field_names.each do |f|
        @proj.redis.exists(@proj.redis_field_key(f)).must_equal(true)
      end
      @proj.purge
    end

  end


  describe "miscellaneous Project methods" do

    it "#to_hash must return hash with numerics where possible" do
      skip
      proj = Project.new(@lc_id_a)
      proj.populate(@doc_a)
      doc_hash = proj.to_hash
      doc_hash.must_be_instance_of(Hash)
      @doc_a[:num_vectors].must_be_instance_of(String)
      doc_hash[:num_vectors].must_be_instance_of(Fixnum)
      proj.delete
    end

    it "integer-based dates resolve to reasonable values" do
      skip
      proj = Project.new(@lc_id_a)
      proj.populate(@doc_a)
      today = Time.now
      drake = Time.parse(Date.parse("1859-08-27").to_s, Time.now)
      test_dates = [ 
        Time.at(proj.newest_file_mod.get.to_i),
        Time.at(proj.oldest_file_mod.get.to_i)
      ]
      test_dates.each do |date_field|
        date_field.between?(drake, today).must_equal(true)
      end
      proj.delete
    end


    it "#try a number will cast a string to a number" do
      skip
      proj = Project.new(@lc_id_a)
      { "one" => "one", "22.22" => 22.22, 3 => 3, "4" => 4}.each do |k,v|
        proj.try_a_number(k).must_equal(v)
      end
      proj.delete
    end

  end


end
