require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require 'sidekiq/testing'
require "test_construct"
Sidekiq::Testing.fake!

require "awesome_print"

require_relative "../../lib/lc_discovery/workers/project_list_worker"


describe ProjectListWorker do
  
  before do
    @proj_home = File.expand_path("../../support", __FILE__)
    @deep_scan = false
  end

  describe "when sidekiq worker is enqueued" do
    include TestConstruct::Helpers

    it "the worker job is added for the correct extract type" do
      ProjectListWorker.perform_async(@proj_home, @deep_scan)
      ProjectListWorker.jobs.size.must_equal(1)
      ProjectListWorker.jobs[0]["args"][0].must_equal(@proj_home)
    end

    it "must fail if wrong number of args supplied" do
      plworker = ProjectListWorker.new

      proc{
        plworker.perform(nil)
      }.must_raise(ArgumentError)

      proc{
        plworker.perform(nil, nil, nil, nil, nil)
      }.must_raise(ArgumentError)
    end

    it "can use redis to publish status and write project list" do
      #1. make two invalid and two valid project structures
      within_construct do |construct|
        construct.directory("bogus") do |dir|
          dir.file("foo.txt")
          dir.file("gxdb.db")
          dir.file("project.ggx")
        end
        construct.directory("legit_one") do |dir|
          dir.file("gxdb.db")
          dir.directory("global")
          dir.file("project.ggx")
        end
        construct.directory("legit_two") do |dir|
          dir.file("gxdb.db")
          dir.directory("global")
          dir.file("project.ggx")
        end
        construct.directory("trick") do |dir|
          dir.directory("gxdb.db")
          dir.file("global")
          dir.file("project.ggx")
        end

        #2. crank up a ProjectListWorker on the construct path
        plw = ProjectListWorker.new
        plw.redis.select 1
        plw.jid = "TEST"

        #3. expect the following sequence (most importantly, two :rpush calls)
        plw.redis.expects(:publish).with(
          "lc_relay", 
          "working on lc_discovery_projectlistworker_test")
        plw.redis.expects(:set).with(
          "lc_discovery_projectlistworker_test",
          "working")
        plw.redis.expects(:set).with(
          "lc_discovery_projectlistworker_test",
          "done")
        plw.redis.expects(:rpush).with(
          "lc_discovery_projectlistworker_test_payload",
          "#{construct}/legit_one")
        plw.redis.expects(:rpush).with(
          "lc_discovery_projectlistworker_test_payload",
          "#{construct}/legit_two")

        plw.redis.expects(:expire).twice

        plw.perform(construct.to_s, @deep_scan)
      end

    end


  end

end

