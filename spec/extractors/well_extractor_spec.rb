require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../../lib/lc_discovery/extractors/well_extractor"

describe WellExtractor do


  #wellheader view vs well table!!!!
  before do
    @opts = {
      project: File.expand_path("../../support/sample", __FILE__),
      label: "fakery"
    }
    @fake = {
      wellheader: [
        {uwi: "111", surface_longitude: -122.0, surface_latitude: 37.6},
        {uwi: "222", surface_longitude: -122.2, surface_latitude: 37.4},
        {uwi: "333", surface_longitude: -222.1, surface_latitude: 27.5},
        {uwi: "444", surface_longitude: -122.2, surface_latitude: 97.5},
        {uwi: "555", surface_longitude:  nil, surface_latitude: 37.5}
      ]
    }
    @mini_bulk = 3

    @xtract = WellExtractor.new(@opts)
    @xtract.gxdb[:wellheader].multi_insert(@fake[:well])
  end

  after do
    @xtract.gxdb[:wellheader].delete
  end



  describe "when collecting well stats from a gxdb" do

    it "#parcels must have single job if well count is less than BULK" do
      jobs = WellExtractor.parcels(@opts[:project])
      jobs.must_be_instance_of(Array)
      jobs.size.must_equal((@fake[:well].size/WellExtractor::BULK) + 1)
      jobs[0].must_be_instance_of(Hash)
      jobs[0][:bulk].must_equal(WellExtractor::BULK)
      jobs[0][:mark].must_equal(1)
    end

    it "#parcels must have multiple jobs if well count is greater than BULK" do
      jobs = WellExtractor.parcels(@opts[:project], @mini_bulk)
      jobs.must_be_instance_of(Array)
      jobs.size.must_equal((@fake[:well].size/@mini_bulk) + 1)
      jobs[0].must_be_instance_of(Hash)
      jobs[0].must_equal({bulk: 3, mark:1})
      jobs[1].must_equal({bulk: 3, mark:4})
    end

    it "#extract must collect well docs for specified range" do
      skip
      a_job = WellExtractor.parcels(@opts[:project], @mini_bulk)[0]
      a_job[:bulk].must_equal(@mini_bulk)

      docs = @xtract.extract(a_job[:bulk], a_job[:mark])
      #docs.size.must_equal(a_job[:bulk])
    end

    it "#extract well docs must contain proper fields" do
      skip
      a_job = WellExtractor.parcels(@opts[:project])[0]
      docs = WellExtractor.new(@opts).extract(a_job[:bulk], a_job[:mark])
      puts "..............."
      a_job
      puts "..............."

    end

  end


end
