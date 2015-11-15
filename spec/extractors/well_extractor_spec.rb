require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../../lib/lc_discovery/extractors/well_extractor"
require_relative "../../lib/lc_discovery/models/well"

describe WellExtractor do


  #wellheader view vs well table!!!!
  before do
    @opts = {
      project: File.expand_path("../../support/sample", __FILE__),
      label: "fakery"
    }
    @fake = {
      wellheader: [
        {:"well id" => "111", longitude: -122.0, latitude: 37.6},
        {:"well id" => "222", longitude: -122.2, latitude: 37.4},
        {:"well id" => "333", longitude: -222.1, latitude: 27.5},
        {:"well id" => "444", longitude: -122.2, latitude: 97.5},
        {:"well id" => "555", longitude:  nil, latitude: 37.5}
      ]
    }
    @mini_bulk = 3

    @xtract = WellExtractor.new(@opts)
    @xtract.gxdb[:wellheader].multi_insert(@fake[:wellheader])
  end

  after do
    @xtract.gxdb[:wellheader].delete
  end



  describe "when collecting well stats from a gxdb" do

    it "creates a WellExtractor object" do
      @xtract.must_be_instance_of(WellExtractor)
    end

    it "#parcels must have single job if well count is less than BULK" do
      jobs = WellExtractor.parcels(@opts[:project])
      jobs.must_be_instance_of(Array)
      jobs.size.must_equal((@fake[:wellheader].size/WellExtractor::BULK) + 1)
      jobs[0].must_be_instance_of(Hash)
      jobs[0][:bulk].must_equal(WellExtractor::BULK)
      jobs[0][:mark].must_equal(1)
    end

    it "#parcels must have multiple jobs if well count is greater than BULK" do
      jobs = WellExtractor.parcels(@opts[:project], @mini_bulk)
      jobs.must_be_instance_of(Array)
      jobs.size.must_equal((@fake[:wellheader].size/@mini_bulk) + 1)
      jobs[0].must_be_instance_of(Hash)
      jobs[0].must_equal({bulk: 3, mark:1})
      jobs[1].must_equal({bulk: 3, mark:4})
    end

    it "#extract must collect well docs for specified range" do
      a_job = WellExtractor.parcels(@opts[:project], @mini_bulk)[0]
      a_job[:bulk].must_equal(@mini_bulk)
      docs = @xtract.extract(a_job[:bulk], a_job[:mark])
      docs.size.must_equal(a_job[:bulk])
    end

    #it "#extract must be a hash with all expected keys" do
    #  a_doc = @xtract.extract[0]
    #  a_doc.must_be_instance_of(Hash)
    #  a_doc.keys.sort.must_equal(Meta.field_names.sort)
    #end
    it "#extract doc must be a hash with all expected keys" do
      a_job = WellExtractor.parcels(@opts[:project])[0]
      a_doc = WellExtractor.new(@opts).extract(a_job[:bulk], a_job[:mark])[0]
      a_doc.must_be_instance_of(Hash)
      a_doc.keys.sort.must_equal(Well.field_names.sort)
    end

  end


end
