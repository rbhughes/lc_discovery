require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../../lib/lc_discovery/models/well"
require_relative "../../lib/lc_discovery/utility"

describe Well do

  describe "constants and meta-info" do

    it "FIELDS is present and contains base_doc keys" do
      Well::FIELDS.must_be_instance_of(Hash)
      base_keys = Utility.base_doc("fake_path", "fake_label").keys
      ((Well::FIELDS.keys & base_keys).sort == base_keys.sort).must_equal(true)
    end

    it "has the expected index name" do
      Well.index_name.must_equal("discovery_wells")
    end

  end

end

