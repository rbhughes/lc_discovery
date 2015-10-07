require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../lib/lc_discovery/publisher"


describe Publisher do


  # There's a holy war against "before(:all) and after(:all) behavior, so just
  # recreate the discovery_test_docs index here. The memoized init should help 
  # Also, not the "self.class" bit since (I think) spec uses anonymous classes
  def self.setup_index
    @setup_index ||= begin
                       unless(Utility.elasticsearch_index_present?(:test_doc))
                         Utility.init_elasticsearch_index(:test_doc)
                       end
                     end

  end

  describe "when #write is invoked" do

    before do
      self.class.setup_index.must_equal(true)
      @doc = {
        id: "test_id",
        label: "test_label",
        project_id: "test_project_id",
        project_name: "test_project_name",
        project_path: "c:\\test project\\path",
        test_thing: "test_thing_field"
      }
      @publisher = Publisher.new
    end


    it "must write to elasticsearch if specified by store" do
      @publisher.redis.expects(:publish).with(
        "lc_relay", "Writing 1 TestDoc docs to elasticsearch.")

      @publisher.write(:test_doc, [@doc], "elasticsearch")

      model = Utility.invoke_lc_model(:test_doc)
      model.to_s.must_equal("TestDoc")
      doc = model.find(@doc[:id])
      doc.must_be_instance_of(model)
      doc.errors.messages.must_be_empty
      doc.attributes.size.must_equal(@doc.size + 2) # created_at + updated_at
      dead = model.find(@doc[:id]).destroy # clean up to be polite
      dead["found"].must_equal(true)
    end


    it "must write to stdout by default if store is nil" do
      proc {
        @publisher.write(:test_doc, [@doc], nil)
      }.must_output(/test_project_id/)
    end


    it "must return nil if there are no docs to write" do
      @publisher.write(:test_doc, [], nil).must_be_nil
    end

  end

end


