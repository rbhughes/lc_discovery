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

  attr_reader :id
  value :lc_id, expiration: Utility::REDIS_EXPIRY

  value :kid_field_one, ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :kid_field_two, ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :kid_ssn,       ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :num_toys,      ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :num_crayons,   ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :oldest_crayon, ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :newest_crayon, ilk: :test, expiration: Utility::REDIS_EXPIRY
  set   :playmates,     ilk: :test, expiration: Utility::REDIS_EXPIRY

  def self.lc_id_fields
    [:project_id, :kid_ssn]
  end

  def self.lc_id(doc)
    lc_id_fields.map{ |x| doc[x] }.join(":")
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

    @lc_id_a = Kid.lc_id(@doc_a)
    @lc_id_b = Kid.lc_id(@doc_b)

    @kid_a = Kid.new(@lc_id_a)
    @kid_a.populate(@doc_a)
    @kid_b = Kid.new(@lc_id_b)
    @kid_b.populate(@doc_b)
  end

  def cleanup
    @kid_a.delete
    @kid_b.delete
    ap "!"*1000 unless (Kid.redis.keys "*").empty?
  end



  describe "when creating and deleting a single Kid object" do

    it "#lc_id generates the expected key string" do
      id = "my_label:my_project_host:my_norm_proj_path:123-45-6789"
      Kid.lc_id(@doc_a).must_equal(id)
      cleanup
    end

    it "#new should create the lc_id field that captures the id" do
      @kid_a.lc_id.get.must_equal(@lc_id_a)
      @kid_a.id.must_equal(@lc_id_a)
      cleanup
    end

    it "#exists? should check if a Kid exists for string, object or hash" do
      as_string = Kid.lc_id(@doc_a)
      as_kid = Kid.new(as_string)
      as_hash = @doc_a
      #_____
      as_string.must_be_instance_of(String)
      as_kid.must_be_instance_of(Kid)
      as_hash.must_be_instance_of(Hash)
      #_____
      Kid.exists?(as_string).must_equal(true)
      Kid.exists?(as_kid).must_equal(true)
      Kid.exists?(as_hash).must_equal(true)
      #_____
      Kid.exists?("bogus").must_equal(false)
      Kid.exists?(Object.new).must_equal(false)
      Kid.exists?({boom:"slang"}).must_equal(false)
      cleanup
    end

    # just compares strings for now (not an ORM)
    it "#populate loads expected document attributes" do
      @kid_a.redis_objects.each do |o|
        field = o[0]
        next if [:lc_id].include?(field)
        redis_type = o[1][:type] 
        case redis_type
        when :value
          @kid_a.method(field).call.value.to_s.must_equal(@doc_a[field].to_s)
        when :set
          @kid_a.method(field).call.members.sort.must_equal(
            @doc_a[:playmates].map(&:to_s).sort
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
      @kid_a.redis_objects.each do |o|
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



  describe "when using Kid#find with lc_id strings (array or single)" do

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
      results = Kid.find(@lc_id_a)
      results.size.must_equal(1)
      found = results[0]
      found = Kid.find(@lc_id_a)[0]
      found.to_hash.must_equal(@kid_a.to_hash)
      cleanup
    end

    it "Kid#find with array of lc_id strings returns array of Kids" do 
      results = Kid.find(["nope_one", @lc_id_a, @lc_id_b])
      results.size.must_equal(2)
      results.must_be_instance_of(Array)
      results[0].must_be_instance_of(Kid)
      cleanup
    end

  end



  describe "when using Kid#find_by with hash of lc_id sub-key matchers" do

    it "#find_by will pass non-hash args to Base#find" do
      results = Kid.find_by("just-a-string")
      results.must_be_instance_of(Array)
      results.must_be_empty
      results = Kid.find_by([@lc_id_a, @lc_id_b])
      results.must_be_instance_of(Array)
      results.size.must_equal(2)
      cleanup
    end

    it "#find_by will return nothing if match is not possible" do
      args = {
        label: @doc_a[:label],
        project_host: "nope" # would be "my_project_host" to match
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
    end

    it "#find_by can discriminate using child's lc_id field (like kid_ssn)" do
      args = {
        kid_ssn: @doc_a[:kid_ssn],
      }
      results = Kid.find_by(args)
      results.must_be_instance_of(Array)
      results.size.must_equal(1)
      results[0].to_hash.must_equal(@kid_a.to_hash)
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
    end

  end



  describe "when checking a Kid object's Redis fields" do

    it "has a proper Redis instance defined" do
      @kid_a.redis.to_s.must_match(/Redis::Objects/)
      cleanup
    end

    it "a Kid object has expected fields defined" do
      fields = Kid.field_names
      count = fields.size
      fields.each do |f|
        @kid_a.redis_objects.keys.must_include(f)
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
      Base.stubs(:lc_id_fields).returns([]) 
      s = Base.matcher_string(@args)
      s.must_equal("base:*:fake_host:*:lc_id")
    end

    it "Base#matcher_string uses project_id sub-fields if present" do
      Base.stubs(:lc_id_fields).returns([]) 
      @args[:project_id] = "bogus:project:stuff"
      s = Base.matcher_string(@args)
      s.must_equal("base:*:fake_host:*:lc_id")
    end

    it "Base#matcher_string will not add unknown fields" do
      Base.stubs(:lc_id_fields).returns([]) 
      @args[:unknown] = "ignored"
      s = Base.matcher_string(@args)
      s.wont_match(/ignored/)
      s.must_equal("base:*:fake_host:*:lc_id")
    end

    it "Base#matcher_string includes fields from lc_id_fields" do
      Base.stubs(:lc_id_fields).returns([:first_name, :last_name]) 
      @args[:first_name] = "sherlock"
      @args[:last_name] = "holmes"
      s = Base.matcher_string(@args)
      s.must_equal("base:*:fake_host:*:sherlock:holmes:lc_id")
    end

  end


end
