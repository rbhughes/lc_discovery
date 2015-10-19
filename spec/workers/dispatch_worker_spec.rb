require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

require_relative "../../lib/lc_discovery/workers/dispatch_worker"


describe DispatchWorker do
  
  before do
    @path = "c:/temp"
    @label = "fake"
    @store = "stdout"
    @extract = "TEST"
  end

  describe "when sidekiq worker is enqueued" do

    it "the worker job is added for the correct extract type" do
      DispatchWorker.perform_async(@extract, @path, @label, @store)
      DispatchWorker.jobs.size.must_equal(1)
      DispatchWorker.jobs[0]["args"][0].must_equal(@extract)
    end


    it "must fail if wrong number of args supplied" do
      dispatch = DispatchWorker.new

      proc{
        dispatch.perform(nil)
      }.must_raise(ArgumentError)

      proc{
        dispatch.perform(nil, nil, nil, nil, nil)
      }.must_raise(ArgumentError)
    end


    # could not declare TestWorker constants multiple times, so two tests here
    it "Sidekiq logger catches unknown extract type, redis.publish called" do
      dispatch = DispatchWorker.new
      dispatch.redis.stubs(:publish).returns("pub")

      DispatchWorker::TestWorker = mock("test_worker")
      DispatchWorker::TestWorker.expects(:perform_async)

      logger_a = capture_subprocess_io do
        dispatch.redis.expects(:publish).twice
        dispatch.perform("EELS", @path, @label, @store)
      end
      logger_a.join.must_match(/ERROR: unknown extract type: EELS/)

      logger_b = capture_subprocess_io do
        dispatch.redis.expects(:publish).twice
        dispatch.perform(@extract, @path, @label, @store)
      end
      logger_b.join.must_be_empty

    end

  end

end
