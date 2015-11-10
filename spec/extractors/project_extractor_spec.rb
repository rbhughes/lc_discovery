require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require "test_construct"
require 'mocha/mini_test'
require_relative "../../lib/lc_discovery/extractors/project_extractor"

describe ProjectExtractor do

  before do
    @opts = {
      project: "x:/fake_home/fake_project",
      label: "fakery"
    }
    proc{ @xtract = ProjectExtractor.new(@opts) }.must_output(/Cannot access/)
  end


  describe "when initialized with options" do

    it "creates a ProjectExtractor object" do
      @xtract.must_be_instance_of(ProjectExtractor)
    end

    it "#activity_score must return an average of non-nil age scores" do
      ages = {age_a: 100, age_b: 200, age_c: nil, age_d: 250}
      @xtract.activity_score(ages).must_equal(183)
    end

    it "#purge_ages must remove hash keys starting with 'age'" do
      mixed_doc = {age_a: 100, age_b: 200, foo_c: nil, foo_d: 250}
      noage_doc = @xtract.purge_ages(mixed_doc)
      noage_doc.must_equal({foo_c: nil, foo_d: 250})
    end

    it "#initialize must not create instance variables with bad project path" do
      @xtract.gxdb.must_be_nil
      @xtract.project.must_be_nil
      @xtract.label.must_be_nil
    end

    it "#extract must handle invalid project path by returning empty array" do
      docs = @xtract.extract
      docs.must_be_instance_of(Array)
      docs.must_be_empty
    end



  end

  describe "when collecting filesystem stats" do
    include TestConstruct::Helpers

    it "#interpreters must collect a list of subfolders from User Files" do
      within_construct do |construct|
        construct.directory('User Files') do |dir|
          @opts[:project] = construct.to_s
          @xtract = ProjectExtractor.new(@opts)

          dir.directory("user_a")
          dir.directory("user_b")
        end
        test_interps = Dir["User Files/*"].map{|x| File.basename(x)}
        interps = @xtract.interpreters
        interps.must_be_instance_of(Hash)
        interps[:interpreters].must_equal(test_interps)
      end
    end

    it "#version_and_coordsys must parse geo info xml or return empty hash" do
      within_construct do |construct|
        @opts[:project] = construct.to_s
        @xtract = ProjectExtractor.new(@opts)
        geo_info = @xtract.version_and_coordsys

        geo_info.must_be_instance_of(Hash)
        geo_info.size.must_equal(5)
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

        geo_info = @xtract.version_and_coordsys
        geo_info.must_be_instance_of(Hash)
        geo_info.size.must_equal(5)
        geo_info[:schema_version].must_equal("fake_proj_vers")
        geo_info[:db_coordsys].must_equal("fake_stor_sys")
        geo_info[:map_coordsys].must_equal("fake_map_sys")
        geo_info[:esri_coordsys].must_equal("fake_esri_sys")
        geo_info[:unit_system].must_equal("fake_unit")
      end
      
    end

    it "#proj_file_stats must recurse a dir and collect file stats" do
      within_construct do |construct|
        @opts[:project] = construct.to_s
        @xtract = ProjectExtractor.new(@opts)

        construct.file("a_interp.svx")
        construct.file("b_interp.svx")
        construct.file("bigmap.gmp")
        construct.file("lilmap.gmp")
        construct.file("down/under/map2.gmp")
        construct.file("esri.shp")
        construct.file("gxdb.db")
        construct.file("gxdb.dbR")
        construct.file("gxdb.log")

        ancient = Time.at(0)
        File.utime(ancient, ancient, "gxdb.log")

        # this is how we would mock File::Stat if that worked here
        #mystat = mock("file::stat")
        #mystat.stubs(size: 111, mtime: Time.new("2000-10-10"))
        #File.stubs(:stat).returns(mystat) 

        pfs = @xtract.proj_file_stats
        pfs.must_be_instance_of(Hash)

        pfs[:num_layers_maps].must_equal(4)
        pfs[:num_sv_interps].must_equal(2)
        pfs[:file_count].must_equal(9)
        pfs[:human_size].must_be_instance_of(String)
        pfs[:byte_size].must_equal(0)

        # gxdb.db, gxdb_production.log and gxdb.log mtime are skipped and not
        # part of age_file_mod or subsequent activity_score...
        pfs[:age_file_mod].must_equal(0)

        # ...but oldest_file_mod should include the ancient date
        Time.at(pfs[:oldest_file_mod]).must_equal(ancient)

      end
    end

    it "#days_since must return number of days since a past date" do
      fortnight = (Date.today - 14).to_time
      @xtract.days_since(fortnight).must_equal(14)
    end

  end
 
  describe "when collecting database stats" do

    before do
      fake = {
        well: [
          {uwi: "111", surface_longitude: -122.0, surface_latitude: 37.6},
          {uwi: "222", surface_longitude: -122.2, surface_latitude: 37.4},
          {uwi: "333", surface_longitude: -222.1, surface_latitude: 27.5},
          {uwi: "444", surface_longitude: -122.2, surface_latitude: 97.5},
          {uwi: "555", surface_longitude:  nil, surface_latitude: 37.5}
        ],
        dig1: [
          {wellid: "111", curveset: "set_a"},
        ],
        dig2: [
          {wellid: "111", curveset: "set_a", curvename: "name_a", version: 1},
          {wellid: "111", curveset: "set_a", curvename: "name_b", version: 1},
          {wellid: "111", curveset: "set_a", curvename: "name_c", version: 1}
        ],
        ras: [
          {
            well_id: "111", log_section_index: 1, log_section_name: "foo",
            tif_filename: "foo.tif", top_depth: 100, top_left_x_pixel: 1,
            top_left_y_pixel: 2, top_right_x_pixel: 3, top_right_y_pixel: 4,
            base_depth: 999, bottom_left_x_pixel: 11, bottom_left_y_pixel: 22,
            bottom_right_x_pixel: 33, bottom_right_y_pixel: 44,
            update_date: Time.now
          }
        ],
        src: [
          {source: "arya"},
          {source: "rob"},
          {source: "reek"}
        ],
        frm: [
          {uwi: "111", source: "arya", form_id: "eel", form_obs_no: 1},
          {uwi: "111", source: "rob", form_id: "eel", form_obs_no: 1},
          {uwi: "111", source: "rob", form_id: "eel", form_obs_no: 2},
          {uwi: "222", source: "rob", form_id: "pie", form_obs_no: 1},
          {uwi: "333", source: "reek", form_id: "jam", form_obs_no: 1}
        ],
        zon1: [
          {zone_name: "skaro"},
          {zone_name: "endor"},
          {zone_name: "arrakis"}
        ],
        zon2: [
          {zattribute_name: "dalek", zattribute_type: 1},
          {zattribute_name: "ewok", zattribute_type: 1},
          {zattribute_name: "melange", zattribute_type: 1},
          {zattribute_name: "sandworm", zattribute_type: 1}
        ],
        zon3: [
          {uwi: "111", zone_name: "skaro", zattribute_name: "dalek"},
          {uwi: "222", zone_name: "endor", zattribute_name: "ewok"},
          {uwi: "333", zone_name: "arrakis", zattribute_name: "melange"},
          {uwi: "333", zone_name: "arrakis", zattribute_name: "sandworm"}
        ],
        svy: [
          {uwi: "111", survey_id: "srv_a", station_md: 100},
          {uwi: "222", survey_id: "srv_b", station_md: 200},
          {uwi: "333", survey_id: "srv_c", station_md: 150}
        ]

      }
      
      @opts[:project] = File.expand_path("../../support/sample", __FILE__)
      @xtract = ProjectExtractor.new(@opts)

      #These inserts are in proper order. If they were not we would have to use
      #both sequel transaction and the wait_for_commit to avoid FK problems:
      #@xtract.gxdb.transaction do
      #  @xtract.gxdb.run('Set OPTION wait_for_commit = On;')
      @xtract.gxdb[:well].multi_insert(fake[:well])
      @xtract.gxdb[:gx_well_curveset].multi_insert(fake[:dig1])
      @xtract.gxdb[:gx_well_curve].multi_insert(fake[:dig2])
      @xtract.gxdb[:log_image_reg_log_section].multi_insert(fake[:ras])
      @xtract.gxdb[:r_source].multi_insert(fake[:src])
      @xtract.gxdb[:well_formation].multi_insert(fake[:frm])
      @xtract.gxdb[:gx_zone].multi_insert(fake[:zon1])
      @xtract.gxdb[:gx_zattribute].multi_insert(fake[:zon2])
      @xtract.gxdb[:well_zone_intrvl_value].multi_insert(fake[:zon3])
      @xtract.gxdb[:well_dir_srvy_station].multi_insert(fake[:svy])
      #  @xtract.gxdb.run('commit;')
      #end
      
    end


    after do
      @xtract.gxdb[:well].delete
      @xtract.gxdb[:gx_well_curve].delete
      @xtract.gxdb[:gx_well_curve_values].delete
      @xtract.gxdb[:log_image_reg_log_section].delete
      @xtract.gxdb[:r_source].delete
      @xtract.gxdb[:well_formation].delete
      @xtract.gxdb[:gx_zone].delete
      @xtract.gxdb[:gx_zattribute].delete
      @xtract.gxdb[:well_zone_intrvl_value].delete
      @xtract.gxdb[:well_dir_srvy_station].delete
    end


    it "#surface_bounds must collect a bounding box of lon/lat pairs" do
      box = @xtract.surface_bounds
      box[:location][:type].must_equal("polygon")
      box[:location][:coordinates][0].size.must_equal(5) #properly closed poly
      box[:location][:coordinates][0].must_include([-122.2, 37.4])
      box[:location][:coordinates][0].must_include([-122.2, 37.6])
      box[:location][:coordinates][0].must_include([-122.0, 37.6])
      box[:location][:coordinates][0].must_include([-122.0, 37.4])
      box[:location][:coordinates][0].wont_include([nil, 37.5])
    end


    it "#proj_db_stats must collect counts and ages for various data types" do
      # note: the ages get stripped from the final doc
      stats = @xtract.proj_db_stats
      stats[:num_wells].must_equal(5)
      stats[:age_wells].must_equal(0)
      stats[:num_vectors].must_equal(3)
      stats[:age_vectors].must_equal(0)
      stats[:num_rasters].must_equal(1)
      stats[:age_rasters].must_equal(0)
      stats[:num_formations].must_equal(4)
      stats[:age_formations].must_equal(0)
      stats[:num_zone_attr].must_equal(4)
      stats[:age_zone_attr].must_equal(0)
      stats[:num_dir_surveys].must_equal(3)
      stats[:age_dir_surveys].must_equal(0)
    end

    # since we have a real-looking project here...

    it "creates instance variables" do
      @xtract.gxdb.must_be_instance_of(Sequel::SqlAnywhere::Database)
      @xtract.project.must_equal(@opts[:project])
      @xtract.label.must_equal(@opts[:label])
    end

    it "#extract must be a hash with all expected keys" do
      a_doc = @xtract.extract[0]
      a_doc.must_be_instance_of(Hash)
<<<<<<< HEAD:spec/extractors/meta_extractor_spec.rb
      a_doc.keys.sort.must_equal(Meta.key_names.sort)

=======
      a_doc.keys.sort.must_equal(Project.field_names.sort)
>>>>>>> work:spec/extractors/project_extractor_spec.rb
    end

  end


end
