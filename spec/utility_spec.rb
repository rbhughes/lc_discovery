require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../lib/lc_discovery/utility"
require_relative "../lib/lc_discovery/lc_env"
require_relative "../lib/lc_discovery/models/test_doc"

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

    before do
      @es_url = LcEnv.elasticsearch_url

    end

    it "#base_doc" do
    end

    it "#fwd_slasher" do
    end

    it "#lc_id" do
    end

    it "#lc_id" do
    end

    it "#camelized_class" do
    end

    it "#lowercase_symbol_keys" do
    end

    it "#invoke_lc_model" do
    end

    # assumes you have rights to drop/create the test index
    # maybe: settings = JSON.parse(Net::HTTP.get(settings_uri))
    it "#init_elasticsearch_index can create an index with settings/mappings" do

      begin
        uri = URI("#{@es_url}/_cat/indices")
        all = Net::HTTP.get(uri).split("\n").map{|x| x.split[2]}

        if(all.include?("discovery_test_docs"))
          uri = URI("#{@es_url}/discovery_test_docs")
          http = Net::HTTP.new(uri.host, uri.port)
          req = Net::HTTP::Delete.new(uri.path)
          http.request(req).must_be_instance_of(Net::HTTPOK)
        end

        Utility.init_elasticsearch_index(:test_doc)
        
        uri = URI("#{@es_url}/_cat/indices")
        all = Net::HTTP.get(uri).split("\n").map{|x| x.split[2]}

        all.include?("discovery_test_docs").must_equal(true)

        
        settings_uri = URI("#{@es_url}/discovery_test_docs/_settings")
        settings = Net::HTTP.get(settings_uri)
        settings.must_match(/settings/)
        
        mappings_uri = URI("#{@es_url}/discovery_test_docs/_mappings")
        mappings = Net::HTTP.get(mappings_uri)
        mappings.must_match(/mappings/)
      rescue Errno::ECONNREFUSED => e
        puts "(Could not initialize Elasticsearch. Is the service running?)"
        e.message.must_match(/^No connection could be made/)
      end
      
    end

    it "#drop_elasticsearch_index" do
    end

    it "#elasticsearch_index_present?" do
    end


    it "#cli_extract" do
      #def cli_extract(extract, path, label, store)


    end

  end

end
