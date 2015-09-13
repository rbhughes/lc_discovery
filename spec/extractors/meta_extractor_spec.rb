require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require "test_construct"
require 'mocha/mini_test'
require_relative "../../lib/lc_discovery/extractors/meta_extractor"

describe MetaExtractor do

  before do
    @opts = {
      project: "x:/fake_home/fake_project",
      label: "fakery"
    }
    @meta_x = MetaExtractor.new(@opts)
  end

  describe "when initialized with options" do

    it "creates a MetaExtractor object" do
      @meta_x.must_be_instance_of MetaExtractor
    end

    it "#project_server with UNC project must parse the server name" do
      @opts[:project] = "\\\\fake_server\\fake_home\\fake_unc_proj" 
      @meta_x = MetaExtractor.new(@opts)
      @meta_x.project_server.must_equal "fake_server"
    end

    it "#project_server with drive letter project must use localhost" do
      hostname = Socket.gethostname
      @meta_x.project_server.must_equal hostname
    end

    it "#project_name must parse the project's name" do
      @meta_x.project_name.must_equal "fake_project"
    end 

    it "#lc_id must generate a predictable hash" do
      @meta_x.lc_id.must_equal "aa49d2a43d59a8a79da2a858cf50fa7c9dc5849f"
    end

    it "#project_home must parse the project's home from home.ini" do
      Discovery.stubs(:parse_home).returns("home_from_ini") 
      @meta_x.project_home.must_equal "home_from_ini"
    end

    it "#base_doc must create a hash for later additions" do
      Discovery.stubs(:parse_home).returns("home_from_ini") 
      @meta_x.base_doc.must_be_instance_of Hash
    end

    it "#activity_score must return an average of non-nil age scores" do
      ages = {age_a: 100, age_b: 200, age_c: nil, age_d: 250}
      @meta_x.activity_score(ages).must_equal 183
    end

  end

  describe "when collecting stats from the filesystem" do
    include TestConstruct::Helpers

    it "#interpreters must collect a list of subfolders from User Files" do
      within_construct do |construct|
        construct.directory('User Files') do |dir|
          @opts[:project] = construct
          @meta_x = MetaExtractor.new(@opts)

          dir.directory("user_a")
          dir.directory("user_b")
        end
        test_interps = Dir["User Files/*"].map{|x| File.basename(x)}
        interps = @meta_x.interpreters
        interps.must_be_instance_of Hash
        interps[:interpreters].must_equal test_interps
      end
    end

    it "#version_and_coordsys must parse geo info xml or return empty hash" do
      within_construct do |construct|
        @opts[:project] = construct
        @meta_x = MetaExtractor.new(@opts)
        geo_info = @meta_x.version_and_coordsys

        geo_info.must_be_instance_of Hash
        geo_info.size.must_equal 5
        geo_info.values.compact.must_be_empty

        construct.file("Project.ggx.xml") do |file|
          file << "<ggx><Project>\n"
          file << "<ProjectVersion>fake_proj_vers</ProjectVersion>\n"
          file << "  <StorageCoordinateSystem>\n"
          file << "    <GGXC1>fake_stor_sys</GGXC1>"
          file << "  </StorageCoordinateSystem>\n"
          file << "  <DisplayCoordinateSystem>"
          file << "    <GGXC1>fake_map_sys</GGXC1>"
          file << "    <ESRI>fake_esri_sys</ESRI>"
          file << "  </DisplayCoordinateSystem>"
          file << "  <UnitSystem>fake_unit</UnitSystem>\n"
          file << "</ggx></Project>\n"
        end

        geo_info = @meta_x.version_and_coordsys
        geo_info.must_be_instance_of Hash
        geo_info.size.must_equal 5
        geo_info[:schema_version].must_equal "fake_proj_vers"
        geo_info[:db_coordsys].must_equal "fake_stor_sys"
        geo_info[:map_coordsys].must_equal "fake_map_sys"
        geo_info[:esri_coordsys].must_equal "fake_esri_sys"
        geo_info[:unit_system].must_equal "fake_unit"
      end
      
    end

    it "#proj_file_stats must recurse a dir and collect file stats" do
      within_construct do |construct|
        @opts[:project] = construct
        @meta_x = MetaExtractor.new(@opts)

        construct.file("a_interp.svx")
        construct.file("b_interp.svx")
        construct.file("bigmap.gmp")
        construct.file("lilmap.gmp")
        construct.file("down/under/map2.gmp")
        construct.file("esri.shp")
        construct.file("gxdb.db")
        construct.file("gxdb.dbR")
        construct.file("gxdb.log")

        ancient = Time.new("1999-12-31")
        File.utime(ancient, ancient, "gxdb.log")

        # this is how we would mock stat if that worked here
        #mystat = mock("file::stat")
        #mystat.stubs(size: 111, mtime: Time.new("2000-10-10"))
        #File.stubs(:stat).returns(mystat) 

        pfs = @meta_x.proj_file_stats
        pfs.must_be_instance_of Hash

        pfs[:num_layers_maps].must_equal 4
        pfs[:num_sv_interps].must_equal 2
        pfs[:file_count].must_equal 9
        pfs[:human_size].must_be_instance_of String
        pfs[:byte_size].must_equal 0

        # gxdb.db, gxdb_production.log and gxdb.log mtime are skipped and not
        # part of age_file_mod or subsequent activity_score...
        pfs[:age_file_mod].must_equal 0
        # ...but oldest_file_mod catches the ancient date
        Time.new(pfs[:oldest_file_mod]).must_equal ancient 

        Date.parse(pfs[:oldest_file_mod]).must_be_instance_of Date
        Date.parse(pfs[:newest_file_mod]).must_be_instance_of Date
      end
    end

    it "#days_since must return number of days since a past date" do
      fortnight = (Date.today - 14).to_time
      @meta_x.days_since(fortnight).must_equal(14)
    end



  end

  describe "when collecting stats from the gxdb" do

  end

end



