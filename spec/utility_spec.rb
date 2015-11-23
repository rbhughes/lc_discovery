require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../lib/lc_discovery/utility"
require_relative "../lib/lc_discovery/lc_env"

require "awesome_print"

describe Utility do


  describe "when mixin methods are used" do

    it "#redis instance method must return a Redis handle" do
      begin
        util = Object.new
        util.extend(Utility)
        util.redis.must_be_instance_of(Redis)
        util.redis.info.must_be_instance_of(Hash)
      rescue Redis::CannotConnectError => e
        puts "(Could not initialize Utility#redis. Is the service running?)"
        e.message.must_match(/^Error connecting to Redis/)
      end
    end

  end


  describe "when class methods are invoked" do

    it "#redis instance method must return a Redis handle" do
      begin
        Utility.redis_pool.must_be_instance_of(ConnectionPool)
      rescue Redis::CannotConnectError => e
        puts "(Could not initialize Utility#redis. Is the service running?)"
        e.message.must_match(/^Error connecting to Redis/)
      end
    end


    it "#base_doc creates a base document hash with expected attributes" do
      doc = Utility.base_doc("c:\\temp\\fake_home\\fake_proj", "fake_label")
      doc[:label].must_equal("fake_label")
      doc[:project_id].must_equal("fake_label:spinoza:c_temp_fake_home_fake_proj")
      doc[:project_path].must_equal("c:\\temp\\fake_home\\fake_proj")
      doc[:project_name].must_equal("fake_proj")
      doc[:project_home].must_equal("fake_home")
      doc[:project_host].must_be_instance_of(String)
    end

    it "#fwd_slasher" do
      s1 = "\\\\typical\\unc\\path to place"
      s2 = nil
      s3 = "no slashes"
      s4 = "mix/ed\\\nslash\\es//here\tyall"
      s5 = "//already/shashed"
      Utility.fwd_slasher(s1).must_equal("//typical/unc/path to place")
      Utility.fwd_slasher(s2).must_be_nil
      Utility.fwd_slasher(s3).must_equal(s3)
      Utility.fwd_slasher(s4).must_equal("mix/ed/\nslash/es//here\tyall")
      Utility.fwd_slasher(s5).must_equal(s5)
    end

    it "#to_iso_date returns an iso date string given an integer" do
      iso = Utility.to_iso_date(1447198943)
      iso.must_be_instance_of(String)
      iso.must_equal("2015-11-10T23:42:23Z")
    end

    it "#lowercase_symbol_keys normalizes hash keys (mainly in db schemas)" do
      h = {
        "AAA" => "val_a",
        :"bB_B" => "val_b",
        "C And C" => "val_c",
        :ddd => "val_d"
      }
      new_h = Utility.lowercase_symbol_keys(h)
      new_h.keys.sort.must_equal([:aaa, :bb_b, :c_and_c, :ddd])
    end


    # Extractors are fully tested elsewhere. This mainly tests instantiation.)
    it "#cli_extract initializes and runs an extractor" do
      skip
      valid_path = File.expand_path("../support/sample", __FILE__)
      bogus_path = "c:/crudler"
      proc {
        Utility.cli_extract(:project, valid_path, "a_label", "stdout")
      }.must_output(/interpreters/)

      proc {
        Utility.cli_extract(:project, bogus_path, "a_label", "stdout").class
      }.must_output(/Cannot access/)
    end

  end

end
