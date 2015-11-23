require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require "mocha/mini_test"
require "redis-objects"
require_relative "../../lib/lc_discovery/models/base"
require_relative "../../lib/lc_discovery/utility"
require 'date'

require "awesome_print"


################################################################################
class Kid < Base
  include Redis::Objects
  self.redis_prefix = self.to_s.downcase

  value :kid_field_one, ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :kid_field_two, ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :kid_ssn,       ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :num_toys,      ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :num_crayons,   ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :oldest_crayon, ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :newest_crayon, ilk: :test, expiration: Utility::REDIS_EXPIRY
  set   :playmates,     ilk: :test, expiration: Utility::REDIS_EXPIRY

  def self.id_fields
    [:project_id, :kid_ssn]
  end

  def self.gen_id(doc)
    id_fields.map{ |x| doc[x] }.join(":")
  end

  Redis::Objects.redis = Utility.redis_pool
end
################################################################################

describe Base do

  before do
    @doc_a = { 
      project_id: "my_label:my_project_host:my_norm_proj_path",
      label: "my_label", 
      project_path: "\\\\my\\norm\\proj\\path",
      project_name: "my_project_name",
      project_home: "my_project_home",
      project_host: "my_project_host",
      kid_field_one: "aaaaa",
      kid_field_two: "bbbbb",
      kid_ssn: "123-45-6789",
      num_toys: "3",
      num_crayons: 64,
      oldest_crayon: 1446591771,
      newest_crayon: 1446593771,
      playmates: ["bonnie", "clyde", 345.444]
    }

    @doc_b = @doc_a.merge({
      label:"HUFFLEPUFF", 
      kid_ssn: "888-88-8888",
      project_id: "HUFFLEPUFF:my_project_host:my_norm_proj_path",
    })

    @id_a = Kid.gen_id(@doc_a)
    @id_b = Kid.gen_id(@doc_b)

    @kid_a = Kid.new(@id_a)
    @kid_a.populate(@doc_a)
    @kid_b = Kid.new(@id_b)
    @kid_b.populate(@doc_b)

  end

  def cleanup
    @kid_a.delete
    @kid_b.delete
    ap "!"*1000 unless (Kid.redis.keys "*").empty?
  end


  describe "when creating and deleting a single Kid object" do

    it "Base#lc_id generates the expected key string" do
      id = "my_label:my_project_host:my_norm_proj_path:123-45-6789"
      Kid.gen_id(@doc_a).must_equal(id)
      cleanup
    end

    it "Base#parse_id can get lc_id string from various object types" do
      as_string = Kid.gen_id(@doc_a)
      as_kid = Kid.new(as_string)
      as_hash = @doc_a

      as_string.must_be_instance_of(String)
      as_kid.must_be_instance_of(Kid)
      as_hash.must_be_instance_of(Hash)

      id_string = Kid.parse_id(as_string)
      id_kid = Kid.parse_id(as_kid)
      id_hash = Kid.parse_id(as_hash)

      id_string.must_equal(@id_a)
      id_kid.must_equal(@id_a)
      id_hash.must_equal(@id_a)
      cleanup
    end

    it "Base#exists? should check if a Kid exists for string, object or hash" do
      as_string = Kid.gen_id(@doc_a)
      as_kid = Kid.new(as_string)
      as_hash = @doc_a

      as_string.must_be_instance_of(String)
      as_kid.must_be_instance_of(Kid)
      as_hash.must_be_instance_of(Hash)

      Kid.exists?(as_string).must_equal(true)
      Kid.exists?(as_kid).must_equal(true)
      Kid.exists?(as_hash).must_equal(true)

      Kid.exists?("bogus").must_equal(false)
      Kid.exists?(Object.new).must_equal(false)
      Kid.exists?({boom:"slang"}).must_equal(false)
      cleanup
    end

    # just compares strings for now (not an ORM)
    it "#populate loads expected document attributes" do
      @kid_a.all_redis_objects.each do |o|
        field = o[0]
        next if [:lc_id].include?(field)
        redis_type = o[1][:type] 
        case redis_type
        when :value
          @kid_a.method(field).call.get.to_s.must_equal(@doc_a[field].to_s)
        when :set
          @kid_a.method(field).call.get.sort.must_equal(
            @doc_a[field].map(&:to_s).sort
          )
        end
      end
      cleanup
    end

    # note, the redis-objects are still defined because the object reference is
    # not nil yet, but no keys exist in redis--it really does get deleted.
    it "#delete should delete the Kid object and all of its fields" do
      Kid.exists?(@kid_a).must_equal(true)
      @kid_a.delete
      Kid.exists?(@kid_a).must_equal(false)
      @kid_a.all_redis_objects.each do |o|
        field = o[0]
        redis_type = o[1][:type] 
        case redis_type
        when :value
          @kid_a.method(field).call.value.must_be_nil
        when :set
          @kid_a.method(field).call.members.must_be_empty
        end
      end
      cleanup
    end

    it "#delete should only affect the Kid upon which it is called" do
      Kid.exists?(@kid_a).must_equal(true)
      Kid.exists?(@kid_b).must_equal(true)
      @kid_a.delete
      Kid.exists?(@kid_a).must_equal(false)
      Kid.exists?(@kid_b).must_equal(true)
      cleanup
    end

  end


  describe "when deleting multiple Kid objects" do

    it "Kid#delete accepts an array of lc_ids" do
      Kid.exists?(@kid_a).must_equal(true)
      Kid.exists?(@kid_b).must_equal(true)
      count = Kid.delete([@id_a, @id_b, "bogus"])
      count.must_equal(2)
      Kid.exists?(@kid_a).must_equal(false)
      Kid.exists?(@kid_b).must_equal(false)
      cleanup
    end

    it "Kid#delete accepts a string lc_id" do
      Kid.exists?(@kid_a).must_equal(true)
      Kid.exists?(@kid_b).must_equal(true)
      Kid.delete(@id_a)
      Kid.exists?(@kid_a).must_equal(false)
      Kid.exists?(@kid_b).must_equal(true)
      cleanup
    end

  end


  describe "Kid#find works with various object types" do

    it "Kid#find with invalid lc_id string returns empty array" do
      results = Kid.find("nope")
      results.must_be_instance_of(Array)
      results.must_be_empty
      cleanup
    end

    it "Kid#find with array of invalid lc_id strings returns empty array" do
      results = Kid.find(["nope_one", "nope_two"])
      results.must_be_instance_of(Array)
      results.must_be_empty
      cleanup
    end

    it "Kid#find given valid lc_id string returns single Kid" do
      results = Kid.find(@id_a)
      results.size.must_equal(1)
      found = results[0]
      found = Kid.find(@id_a)[0]
      found.to_hash.must_equal(@kid_a.to_hash)
      cleanup
    end

    it "Kid#find with array of string and Hash returns array of Kids" do 
      results = Kid.find(["nope_one", @id_a, @doc_b])
      results.size.must_equal(2)
      results.must_be_instance_of(Array)
      results[0].must_be_instance_of(Kid)
      results[1].must_be_instance_of(Kid)
      cleanup
    end

    it "Kid#find with array with various dup objects returns unique array" do 
      results = Kid.find(["nope", @id_a, @doc_a, @kid_b, @kid_a, @doc_b])
      results.size.must_equal(2)
      results.must_be_instance_of(Array)
      results[0].must_be_instance_of(Kid)
      results[1].must_be_instance_of(Kid)
      cleanup
    end

  end


  describe "when using Kid#find_by with hash of lc_id sub-key matchers" do

    it "#find_by will pass non-hash args to Base#find" do
      results = Kid.find_by("just-a-string")
      results.must_be_instance_of(Array)
      results.must_be_empty
      results = Kid.find_by([@id_a, @id_b])
      results.must_be_instance_of(Array)
      results.size.must_equal(2)
      cleanup
    end

    it "#find_by will return nothing if match is not possible" do
      args = {
        label: @doc_a[:label],
        project_host: "nope" # would need to be "my_project_host" to match
      }
      results = Kid.find_by(args)
      results.must_be_instance_of(Array)
      results.must_be_empty
      cleanup
    end

    it "#find_by can discriminate using a base field (like label)" do
      args = {
        label: @doc_b[:label],
      }
      results = Kid.find_by(args)
      results.must_be_instance_of(Array)
      results.size.must_equal(1)
      results[0].to_hash.must_equal(@kid_b.to_hash)
      cleanup
    end

    it "#find_by can discriminate using child's lc_id field (like kid_ssn)" do
      args = {
        kid_ssn: @doc_a[:kid_ssn],
      }
      results = Kid.find_by(args)
      results.must_be_instance_of(Array)
      results.size.must_equal(1)
      results[0].to_hash.must_equal(@kid_a.to_hash)
      cleanup
    end

    it "#find_by can return multiple hits if the field matches multiple docs" do
      args = {
        num_crayons: @doc_a[:num_crayons],
      }
      results = Kid.find_by(args)
      results.must_be_instance_of(Array)
      results.size.must_equal(2)
      results[0].must_be_instance_of(Kid)
      results[1].must_be_instance_of(Kid)
      results[0].to_hash.wont_equal(results[1].to_hash)
      cleanup
    end

  end


  describe "when checking a Kid object's Redis fields" do

    it "has a proper Redis instance defined" do
      @kid_a.redis.to_s.must_match(/Redis::Objects/)
      cleanup
    end

    it "a Kid object has expected fields defined" do
      all_fields = Kid.all_redis_objects.keys
      count = all_fields.size
      all_fields.each do |f|
        @kid_a.all_redis_objects.keys.must_include(f)
        @kid_a.redis.exists(@kid_a.redis_field_key(f)).must_equal(true)
        count -= 1
      end
      count.must_equal(0)
      cleanup
    end

  end


  describe "miscellaneous Base methods" do

    before do
      @args = {
        project_host: "fake_host",
        ignore_field: "321452345"
      }
    end

    it "#to_hash must return hash with numerics where possible" do
      doc_hash = @kid_a.to_hash
      doc_hash.must_be_instance_of(Hash)
      @doc_a[:num_toys].must_be_instance_of(String)
      doc_hash[:num_toys].must_be_instance_of(Fixnum)
      cleanup
    end

    it "integer-based dates resolve to reasonable values" do
      today = Time.now
      drake = Time.parse(Date.parse("1859-08-27").to_s, Time.now)
      test_dates = [ 
        Time.at(@kid_a.newest_crayon.get.to_i),
        Time.at(@kid_a.oldest_crayon.get.to_i)
      ]
      test_dates.each do |date_field|
        date_field.between?(drake, today).must_equal(true)
      end
      cleanup
    end

    it "#try a number will cast a string to a number" do
      { "one" => "one", "22.22" => 22.22, 3 => 3, "4" => 4}.each do |k,v|
        @kid_a.try_a_number(k).must_equal(v)
      end
      cleanup
    end

    it "Base#matcher_string returns wildcards for missing project_id fields" do
      Base.stubs(:id_fields).returns([]) 
      s = Base.matcher_string(@args)
      s.must_equal("base:*:fake_host:*:lc_id")
      cleanup
    end

    it "Base#matcher_string uses project_id sub-fields if present" do
      Base.stubs(:id_fields).returns([]) 
      @args[:project_id] = "bogus:project:stuff"
      s = Base.matcher_string(@args)
      s.must_equal("base:*:fake_host:*:lc_id")
      cleanup
    end

    it "Base#matcher_string will not add unknown fields" do
      Base.stubs(:id_fields).returns([]) 
      @args[:unknown] = "ignored"
      s = Base.matcher_string(@args)
      s.wont_match(/ignored/)
      s.must_equal("base:*:fake_host:*:lc_id")
      cleanup
    end

    it "Base#matcher_string includes fields from id_fields" do
      Base.stubs(:id_fields).returns([:first_name, :last_name]) 
      @args[:first_name] = "sherlock"
      @args[:last_name] = "holmes"
      s = Base.matcher_string(@args)
      s.must_equal("base:*:fake_host:*:sherlock:holmes:lc_id")
      cleanup
    end

  end

end
