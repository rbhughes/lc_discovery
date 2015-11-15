require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../lib/lc_discovery/utility"
require_relative "../lib/lc_discovery/lc_env"
require_relative "../lib/lc_discovery/models/test_doc"

require "awesome_print"

describe Utility do

  #def testdoc_index_exists?
  #  uri = URI("#{LcEnv.elasticsearch_url}/_cat/indices")
  #  all = Net::HTTP.get(uri).split("\n").map{|x| x.split[2]}
  #  all.include?("discovery_test_docs") ? true : false
  #end

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

    #before do
    #  @es_url = LcEnv.elasticsearch_url
    #end


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

    #it "#lc_id makes a hash of a string, does some normalization" do
    #  cthul_a = "//Ph'ngLUI mglw'nafh/CthulHU R'lyeh WGAH'nagl fhtagn"
    #  cthul_b = "\\\\Ph'nglui MGLW'nafh\\cthulhu r'lyeh wgah'NAGL fhtagn"
    #  cthul_c = "//Ph'NGlui mglw'nafh/cthulhu r'lyeh wgah'nagl fhtagn"
    #  cthul_d = "\\\\Ph'nglui mglw'nafh\\CTHULHU R'LYEH wgah'nagl FHTAGN"

    #  unspeakable = "6cafb8e2d9dc4c371ec8b9ca4452955cee5b5b1b"

    #  Utility.lc_id(cthul_a).must_equal(unspeakable)
    #  Utility.lc_id(cthul_b).must_equal(unspeakable)
    #  Utility.lc_id(cthul_c).must_equal(unspeakable)
    #  Utility.lc_id(cthul_d).must_equal(unspeakable)
    #end

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


    it "#invoke_lc_model should instantiate an lc_discovery model" do
      Utility.invoke_lc_model(:test_doc).name.must_equal("TestDoc")
      Utility.invoke_lc_model(:test_doc)::FIELDS.must_be_instance_of(Hash)
      Utility.invoke_lc_model("test_doc").name.must_equal("TestDoc")
      proc { Utility.invoke_lc_model(:nope) }.must_raise(LoadError)
    end


    # Assumes you have rights to drop/create the test index and that ES is up
    # maybe: settings = JSON.parse(Net::HTTP.get(settings_uri))
    #begin

      #it "#init_elasticsearch_index creates an index with settings/mappings" do
      #  if testdoc_index_exists?
      #    uri = URI("#{@es_url}/discovery_test_docs")
      #    http = Net::HTTP.new(uri.host, uri.port)
      #    req = Net::HTTP::Delete.new(uri.path)
      #    http.request(req).must_be_instance_of(Net::HTTPOK)
      #  end

      #  Utility.init_elasticsearch_index(:test_doc)
      #  testdoc_index_exists?.must_equal(true)
        
      #  settings_uri = URI("#{@es_url}/discovery_test_docs/_settings")
      #  settings = Net::HTTP.get(settings_uri)
      #  settings.must_match(/settings/)
      #  
      #  mappings_uri = URI("#{@es_url}/discovery_test_docs/_mappings")
      #  mappings = Net::HTTP.get(mappings_uri)
      #  mappings.must_match(/mappings/)
      #end


      #it "#drop_elasticsearch_index deletes an elasticsearch index" do
      #  Utility.init_elasticsearch_index(:test_doc)
      #  Utility.drop_elasticsearch_index(:test_doc)
      #  testdoc_index_exists?.must_equal(false)
      #end


      #it "#elasticsearch_index_present? checks whether an index exists" do
      #  Utility.drop_elasticsearch_index(:test_doc)
      #  a = testdoc_index_exists?
      #  b = Utility.elasticsearch_index_present?(:discovery_test_docs)
      #  a.must_equal(false)
      #  b.must_equal(false)

      #  Utility.init_elasticsearch_index(:test_doc)
      #  c = testdoc_index_exists?
      #  d = Utility.elasticsearch_index_present?(:discovery_test_docs)
      #  c.must_equal(true)
      #  d.must_equal(true)
      #end

    #rescue Errno::ECONNREFUSED => e
    #  puts "(Could not initialize Elasticsearch. Is the service running?)"
    #  e.message.must_match(/^No connection could be made/)
    #end


    # Extractors are fully tested elsewhere. This mainly tests instantiation.)
    it "#cli_extract initializes and runs an extractor" do
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
