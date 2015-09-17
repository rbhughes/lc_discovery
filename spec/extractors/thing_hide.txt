=begin
require 'minitest/autorun'

module MiniTest::Assertions
  def assert_equals_rounded(rounded, decimal)
    assert rounded == decimal.round, "Expected #{decimal} to round to #{rounded}"
  end

  def assert_palindrome(string)
    assert string == string.reverse, "Expected #{string} to read the same way backwards and forwards"
  end

  def assert_default(hash, default_value)
    assert default_value == hash.default, "Expected #{default_value} to be default value for hash but was #{hash.default.inspect}"
  end
end

Numeric.infect_an_assertion :assert_equals_rounded, :must_round_to
String.infect_an_assertion :assert_palindrome, :must_be_palindrome, :only_one_argument
Hash.infect_an_assertion   :assert_default, :must_default_to, :do_not_flip

describe 'custom expectations' do

  describe '#must_round_to' do

    it 'rounds correctly for Float' do
      1.2.must_round_to 1
    end

    it 'rounds correctly for Fixnum' do
      1.must_round_to 1
    end

    it 'catches failures' do
      proc { 1.5.must_round_to 42 }.must_raise(MiniTest::Assertion)
    end

  end

  describe '#must_be_palindrome' do

    it 'reads a string backwards and forwards' do
      'racecar'.must_be_palindrome
    end

    it 'catches failures' do
      proc { 'kriss kross'.must_be_palindrome }.must_raise(MiniTest::Assertion)
    end

    it 'only works for Strings' do
      proc { 1.must_be_palindrome }.must_raise(NoMethodError)
    end

  end

  describe '#must_default_to' do

    it 'compares the default value of a hash' do
      hash = Hash.new(42)
      hash.must_default_to 42
    end

    it 'catches failures' do
      proc { {}.must_default_to 42 }.must_raise(MiniTest::Assertion)
    end

    it 'only works for Hashes' do
      proc { 1.must_default_to 2 }.must_raise(NoMethodError)
    end

  end

end
=end
