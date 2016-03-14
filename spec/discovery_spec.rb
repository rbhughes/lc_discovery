require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require "test_construct"
require 'mocha/mini_test'
require_relative "../lib/lc_discovery/discovery"
require_relative "../lib/lc_discovery/lc_env"


describe Discovery do

  describe "when locating projects by recursing filesystem" do
    include TestConstruct::Helpers

    it "#ggx_project? must match potential projects by file types" do
      within_construct do |construct|
        construct.directory("bogus") do |dir|
          dir.file("foo.txt")
          dir.file("gxdb.db")
          dir.file("project.ggx")
        end
        construct.directory("legit") do |dir|
          dir.file("gxdb.db")
          dir.directory("global")
          dir.file("project.ggx")
        end
        construct.directory("trick") do |dir|
          dir.directory("gxdb.db")
          dir.file("global")
          dir.file("project.ggx")
        end
        Discovery.ggx_project?(File.join(construct, "bogus")).must_equal(false)
        Discovery.ggx_project?(File.join(construct, "legit")).must_equal(true)
        Discovery.ggx_project?(File.join(construct, "trick")).must_equal(false)
      end
    end

    it "#list_projects must recurse to subdirs if deep_scan is true" do
      within_construct do |construct|
        construct.directory("deep/bogus") do |dir|
          dir.file("foo.txt")
          dir.file("gxdb.db")
          dir.file("project.ggx")
        end
        construct.directory("deep/legit") do |dir|
          dir.file("gxdb.db")
          dir.directory("global")
          dir.file("project.ggx")
        end
        construct.directory("trick") do |dir|
          dir.directory("gxdb.db")
          dir.file("global")
          dir.file("project.ggx")
        end

        deep_true = Discovery.project_list(construct.to_s, true)
        deep_false = Discovery.project_list(construct.to_s, false)

        deep_true.size.must_equal(1)
        deep_true[0].must_match(/deep\/legit$/)
        deep_false.size.must_equal(0)

      end
    end

  end


  describe "defining connection strings" do
    include TestConstruct::Helpers

    it "connect_string must abhor spaces in paths" do
      Discovery.connect_string("BL A  N   K").must_match(/BL_A__N___K/)
    end

    it "#connect_string must construct a Sybase SQLAnywhere string" do
      Discovery.stubs(:parse_home).returns("stub_home") 
      Discovery.stubs(:parse_host).returns("stub_host") 
      args = Discovery.connect_string("TEST").split(";")
      args.must_include("UID=dba")
      args.must_include("PWD=sql")
      args.must_include("DBF='TEST/gxdb.db'")
      args.must_include("DBN=TEST-stub_home")
      args.must_include("HOST=stub_host")
      args.must_include("SERVER=GGX_stub_host")
    end

    it "#parse_home must collect home name from home.ini" do
      within_construct do |construct|
        construct.directory("fake_home") do |home|
          home.file("home.ini") do |file|
            file << "[General]\n"
            file << "Name=H O M E\n"
          end
          home.directory("fake_proj") do |proj|
            @proj = proj.to_s
            proj.file("gxdb.db")
            proj.directory("global")
          end
        end
        Discovery.parse_home(@proj).must_equal("H O M E")
      end
    end

    it "#parse_home must settle for parent directory if missing home.ini" do
      within_construct do |construct|
        construct.directory("fake_home") do |home|
          home.directory("fake_proj") do |proj|
            @proj = proj.to_s
            proj.file("gxdb.db")
            proj.directory("global")
          end
        end
        Discovery.parse_home(@proj).must_equal("fake_home")
      end
    end

    it "#parse_host with drive letter path must use localhost" do
      hostname = Socket.gethostname
      path = "c:\\bogus\\home path\project"
      host = Discovery.parse_host(path)
      host.must_equal(hostname)
    end

    it "#parse_host with UNC path must parse server name" do
      path = "\\\\ggx_server\\share\\stuff$"
      host = Discovery.parse_host(path)
      host.must_equal("ggx_server")
    end

  end

  describe "when initializing Discovery::Sybase" do

    it "must create connection if a valid project path is supplied" do
      good_path = File.expand_path("../support/sample", __FILE__)
      Discovery::Sybase.new(good_path).db.test_connection.must_equal(true)
    end

    it "must raise error if an invalid project path is supplied" do
      proc { 
        Discovery::Sybase.new("bogus").db.test_connection 
      }.must_raise(Sequel::DatabaseConnectionError)
    end

    it "Sybase#set_lcenv_sybase_path adds the local Sybase path to PATH" do
      syb_path = Discovery::Sybase.new("bogus").set_lcenv_sybase_path
      syb_path.split(";").must_include(LcEnv.sybase_path)
    end


  end

end


