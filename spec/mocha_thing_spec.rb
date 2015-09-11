class Enterprise
  def initialize(dilithium)
    @dilithium = dilithium
  end

  def go(warp_factor)
    warp_factor.times { @dilithium.nuke(:anti_matter) }
  end

  def say_inst
    "KABOOM"
  end

  def self.say_clas
    "SHAX"
  end

end

#require 'test/unit'
require "minitest/autorun"
require 'mocha/mini_test'
require "test_construct"

#class EnterpriseTest < Test::Unit::TestCase
class EnterpriseTest < MiniTest::Test 
  include TestConstruct::Helpers
  #def test_should_boldly_go
  #  dilithium = mock()
  #  dilithium.expects(:nuke).with(:anti_matter).at_least_once  # auto-verified at end of test
  #  enterprise = Enterprise.new(dilithium)
#
#    enterprise.go(2)
#  end
  #


  def test_construct

    within_construct do |construct|
      skip
      #construct.file('foo.txt') do |file|
      #  file << "Some content\n"
      #  file << "Some more content"
      #end
      
      #construct.directory('foo') do |dir|
      #  dir.file('bar.txt')
      #  assert File.exist?('bar.txt') # This assertion will pass
      #end

      construct.directory('User Files') do |dir|
        dir.directory('user_a')
        dir.directory('user_b')
        #assert File.directory?("user_a")
      end

      #assert File.directory?("User Files")
      x = Dir["User Files/*"]
      puts x
      construct.keep

    end

  end



  def test_enterprise
    skip
    dilithium = mock()
    enterprise = Enterprise.new(dilithium)

    Enterprise.stubs(:say_clas).returns("pigs") 
    enterprise.stubs(:say_inst).returns("pigs")

    #assert_equal "pigs", enterprise.say("otters")
    assert_equal "pigs", Enterprise.say_clas
    assert_equal "pigs", enterprise.say_inst

  end
end
