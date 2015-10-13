require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../../lib/lc_discovery/models/meta"

require "awesome_print"
require_relative "../../lib/lc_discovery/utility"

describe Meta do

  describe "constants and meta-info" do

    it "FIELDS is present and contains base_doc keys" do
      Meta::FIELDS.must_be_instance_of(Hash)
      base_keys = Utility.base_doc("fake_path", "fake_label").keys
      ((Meta::FIELDS.keys & base_keys).sort == base_keys.sort).must_equal(true)
    end

    it "has the expected index name" do
      Meta.index_name.must_equal("discovery_metas")
    end

  end

end
