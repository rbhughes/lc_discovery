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
        big_s = "Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn"
        lil_s = "."

        construct.file("a_interp.svx", lil_s)
        construct.file("b_interp.svx", lil_s)
        construct.file("bigmap.gmp", big_s)
        construct.file("lilmap.gmp", lil_s)
        construct.file("down/under/map2.gmp", lil_s)
        construct.file("esri.shp", lil_s)
        construct.file("gxdb.db", big_s)
        construct.file("gxdb.dbR", lil_s)
        puts "1========"
        puts File.stat("gxdb.dbR").size
        puts "1========"

        #File::Stat.stubs(:mtime).returns(11111)


        class OldAndBigStat
          def self.mtime
            Time.new("2000-01-01")
          end
          def self.size
            100000
          end
        end
        
        File.stubs(:stat).returns(OldAndBigStat)
        construct.file("gxdb.log", big_s)
        
        puts "2========"
        puts File.stat("gxdb.log").size
        puts "2========"

        big_bytes = File.size("bigmap.gmp")
        lil_bytes = File.size("lilmap.gmp")

        pfs = @meta_x.proj_file_stats
        pfs.must_be_instance_of Hash
        puts "..................."
        puts pfs.inspect
        puts "..................."

        pfs[:num_layers_maps].must_equal 4
        pfs[:num_sv_interps].must_equal 2
        pfs[:file_count].must_equal 9
        pfs[:human_size].must_be_instance_of String
        pfs[:byte_size].must_equal (big_bytes*3) + (lil_bytes*6)
        Date.parse(pfs[:oldest_file_mod]).must_be_instance_of Date
        Date.parse(pfs[:newest_file_mod]).must_be_instance_of Date

      end
    end



  end

  describe "when collecting stats from the gxdb" do

  end

end

=begin
describe MetaExtractor do

  before do
    @opts = {
      project: "c:/programdata/geographix/projects/stratton",
      label: "test"
    }
    @meta_extractor = MetaExtractor.new(@opts)
  end

  describe "when initialized with options" do

    it "must be a MetaExtractor object" do
      @meta_extractor.must_be_kind_of MetaExtractor
    end

    it "#project_server must parse the server name" do
      hostname = Socket.gethostname
      @meta_extractor.project_server.must_equal hostname
    end

    it "#project_home must parse the project's home" do
      @meta_extractor.project_home.must_equal "Projects"
    end

    it "#project_name must parse the project's name" do
      @meta_extractor.project_name.must_equal "stratton"
    end 

    it "#lc_id must return hash for this doc's id" do
      id = "c62c5952546ae1761eda490dca9df0ca413d5ad3"
      @meta_extractor.lc_id.must_equal id 
    end 

    it "#base_doc must create a valid base doc" do
      skip
      #doc = @meta_extractor.base_doc
      #doc[:id].must_equal
      #doc[:label].must_equal
      #doc[:project_server].must_equal
      #doc[:project_home].must_equal
      #doc[:project_name].must_equal
    end

    it "dummy test" do


      #filesystem {
      #  file "file_1"
      #  dir "subdir_1" do
      #    file "subfile_1"
      #  end
      #  dir "subdir_2"
      #  dir "subdir_3" do
      #    link "link_1"
      #  end
      #}.must_exist_within "root_dir"
      #

      # YOU GONNA STUB or MOCK the whole Discovery object!
      
      

      File.stub :stat, "sss" do
        x = File.stat("asfd")
        x.must_equal "sss"
      end



      @meta_extractor.stub :project_name, "zerg" do
        #me = MetaExtractor.new(@opts)
        @meta_extractor.project_name.must_equal "zerg"
        @meta_extractor.project_home.must_equal "Projects"
      end

    end

  end


end



=end
