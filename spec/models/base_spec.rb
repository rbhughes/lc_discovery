require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
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
  value :num_toys,      ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :num_crayons,   ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :oldest_crayon, ilk: :test, expiration: Utility::REDIS_EXPIRY
  value :newest_crayon, ilk: :test, expiration: Utility::REDIS_EXPIRY
  set   :playmates,     ilk: :test, expiration: Utility::REDIS_EXPIRY

  def self.lc_id(doc)
    doc[:project_id]
  end

  def self.matcher_fields
    []
  end

  Redis::Objects.redis = Utility.redis_pool
end
################################################################################




describe Base do

  before do
    @args = {
      project_host: "fake_host",
      ignore_field: "321452345"
    }

    @doc_a = { 
      project_id: "fakery:spinoza:c_dev_lc_discovery_spec_support_sample",
      label: "fakery", 
      kid_field_one: "aaaaa",
      kid_field_two: "bbbbb",
      num_toys: "3",
      num_crayons: 64,
      oldest_crayon: 1446591771,
      newest_crayon: 1446593771,
      playmates: ["bonnie", "clyde", 345.444]
    }

    @doc_b = @doc_a.merge({
      label:"boom", 
      project_id: "boom:spinoza:c_dev_lc_discovery_spec_support_sample",
    })

    @lc_id_a = Kid.lc_id(@doc_a)
    @lc_id_b = Kid.lc_id(@doc_b)

  end



  describe "when creating and deleting a single Kid object" do

    it "#lc_id generates the expected key string" do
      expected = "fakery:spinoza:c_dev_lc_discovery_spec_support_sample"
      Kid.lc_id(@doc_a).must_equal(expected)
    end


    it "#new should create the lc_id field that captures the id" do
      kid = Kid.new(@lc_id_a)
      kid.lc_id.get.must_equal(@lc_id_a)
      kid.id.must_equal(@lc_id_a)
      kid.delete
    end


    it "#exists? should check if a Kid exists for string, object or hash" do
      as_string = Kid.lc_id(@doc_a)
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

      as_kid.delete
    end


    #just compares strings
    it "#populate loads expected document attributes" do
      kid = Kid.new(@lc_id_a)
      kid.populate(@doc_a)
      kid.redis_objects.each do |o|
        field = o[0]
        next if [:lc_id].include?(field)
        redis_type = o[1][:type] 
        case redis_type
        when :value
          kid.method(field).call.value.to_s.must_equal(@doc_a[field].to_s)
        when :set
          kid.method(field).call.members.sort.must_equal(
            @doc_a[:playmates].map(&:to_s).sort
          )
        end
      end
      kid.delete
    end


    # note, the redis-objects are still defined because the object reference is
    # not nil yet, but no keys exist in redis--it really did get deleted.
    it "#delete should delete the Kid object and all of its fields" do
      kid = Kid.new(@lc_id_a)
      kid.populate(@doc_a)
      Kid.exists?(kid).must_equal(true)
      kid.delete
      Kid.exists?(kid).must_equal(false)
      kid.redis_objects.each do |o|
        field = o[0]
        redis_type = o[1][:type] 
        case redis_type
        when :value
          kid.method(field).call.value.must_be_nil
        when :set
          kid.method(field).call.members.must_be_empty
        end
      end
    end


    it "#delete should only affect the Kid upon which it is called" do
      kid_a = Kid.new(@lc_id_a)
      kid_a.populate(@doc_a)

      kid_b = Kid.new(@lc_id_b)
      kid_b.populate(@doc_b)

      Kid.exists?(kid_a).must_equal(true)
      Kid.exists?(kid_b).must_equal(true)

      kid_a.delete
      Kid.exists?(kid_a).must_equal(false)
      Kid.exists?(kid_b).must_equal(true)
      kid_b.delete
    end

  end







  describe "when finding Kid objects" do

    it "Kid#find with invalid lc_id string returns empty array" do
      results = Kid.find("nope")
      results.must_be_instance_of(Array)
      results.must_be_empty
    end


    it "Kid#find with array of invalid lc_id strings returns empty array" do
      results = Kid.find(["nope_one", "nope_two"])
      results.must_be_instance_of(Array)
      results.must_be_empty
    end


    it "Kid#find given valid lc_id string returns single Kid" do
      kid = Kid.new(@lc_id_a)
      kid.populate(@doc_a)
      results = Kid.find(@lc_id_a)
      results.size.must_equal(1)
      found = results[0]
      found = Kid.find(@lc_id_a)[0]
      found.id.must_equal(@lc_id_a)
      found.label.get.must_equal(@doc_a[:label])
      found.project_id.get.must_equal(@doc_a[:project_id])
      found.delete
    end


    it "Kid#find with array of lc_id strings returns array of Kids" do 
      kid_a = Kid.new(@lc_id_a)
      kid_a.populate(@doc_a)
      kid_b = Kid.new(@lc_id_b)
      kid_b.populate(@doc_b)

      results = Kid.find(["nope_one", @lc_id_a, @lc_id_b])

      results.size.must_equal(2)
      results.must_be_instance_of(Array)
      results[0].must_be_instance_of(Kid)
      results[0].kid_field_one.get.must_equal(@doc_b[:kid_field_one])
      
      kid_a.delete
      kid_b.delete
    end

    it "#find_by will pass non-hash args to Base#find" do
      kid_a = Kid.new(@lc_id_a)
      results = Kid.find_by("just-a-string")
      results.must_be_instance_of(Array)
      results.must_be_empty
      results = Kid.find_by([@lc_id_a, @lc_id_b])
      results.must_be_instance_of(Array)
      results.size.must_equal(1)
      kid_a.delete
    end

    it "#find_by with project_id in hash discriminates by another field" do
      kid_a = Kid.new(@lc_id_a)
      kid_a.populate(@doc_a)
      kid_b = Kid.new(@lc_id_b)
      kid_b.populate(@doc_b)

      args = {
        project_id: @lc_id_a,
        label: "fakery",
        well_id: "321452345",
        project_host: "spinoza"
      }

      results = Kid.find_by(args)
      ap "."*40
      ap results
      ap "."*40

      kid_a.delete
      kid_b.delete
    end

  end


  describe "when checking a Kid object's Redis fields" do

    it "has a proper Redis instance defined" do
      kid = Kid.new(@lc_id_a)
      kid.redis.to_s.must_match(/Redis::Objects/)
      kid.delete
    end

    it "a Kid object has expected fields defined" do
      kid = Kid.new(@lc_id_a)
      fields = Kid.field_names
      count = fields.size
      fields.each do |f|
        kid.redis_objects.keys.must_include(f)
        kid.redis.exists(kid.redis_field_key(f)).must_equal(false)
        count -= 1
      end
      count.must_equal(0)
      kid.delete
    end

    it "#populate adds attributes that are found by redis exists" do
      kid = Kid.new(@lc_id_a)
      kid.populate(@doc_a)
      Kid.field_names.each do |f|
        kid.redis.exists(kid.redis_field_key(f)).must_equal(true)
      end
      kid.delete
    end

  end







  describe "miscellaneous Base methods" do

    it "#to_hash must return hash with numerics where possible" do
      kid = Kid.new(@lc_id_a)
      kid.populate(@doc_a)
      doc_hash = kid.to_hash
      doc_hash.must_be_instance_of(Hash)
      @doc_a[:num_toys].must_be_instance_of(String)
      doc_hash[:num_toys].must_be_instance_of(Fixnum)
      kid.delete
    end

    it "integer-based dates resolve to reasonable values" do
      kid = Kid.new(@lc_id_a)
      kid.populate(@doc_a)
      today = Time.now
      drake = Time.parse(Date.parse("1859-08-27").to_s, Time.now)
      test_dates = [ 
        Time.at(kid.newest_crayon.get.to_i),
        Time.at(kid.oldest_crayon.get.to_i)
      ]
      test_dates.each do |date_field|
        date_field.between?(drake, today).must_equal(true)
      end
      kid.delete
    end

    it "#try a number will cast a string to a number" do
      kid = Kid.new(@lc_id_a)
      { "one" => "one", "22.22" => 22.22, 3 => 3, "4" => 4}.each do |k,v|
        kid.try_a_number(k).must_equal(v)
      end
      kid.delete
    end

    it "Base#matcher_string returns wildcards for missing project_id fields" do
      Base.stubs(:matcher_fields).returns([]) 
      s = Base.matcher_string(@args)
      s.must_equal("*:fake_host:*")
    end

    it "Base#matcher_string lets project_id trump other fields" do
      Base.stubs(:matcher_fields).returns([]) 
      @args[:project_id] = "bogus:project:id"
      s = Base.matcher_string(@args)
      s.must_equal("bogus:project:id")
    end

    it "Base#matcher_string will not add unknown fields" do
      Base.stubs(:matcher_fields).returns([]) 
      @args[:unknown] = "ignored"
      s = Base.matcher_string(@args)
      s.wont_match(/ignored/)
      s.must_equal("*:fake_host:*")
    end

    it "Base#matcher_string includes fields from matcher_fields" do
      Base.stubs(:matcher_fields).returns([:mystery]) 
      @args[:mystery] = "sherlock"
      s = Base.matcher_string(@args)
      s.must_equal("*:fake_host:*:sherlock")
    end

  end


end
