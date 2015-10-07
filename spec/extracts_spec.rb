require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../lib/lc_discovery/extracts"

describe Extracts do

  describe "when #write is invoked" do

    before do
      @extracts = Extracts.constants
    end


    it "constants must be set (happens when required)" do
      @extracts.must_be_instance_of(Array)
      @extracts.wont_be_empty
      @extracts[0].must_be_instance_of(Symbol) # weird, but from const_set
    end


    it "#data_types_for_cli outputs a string with index for CLI selection" do
      Extracts.data_types_for_cli.each_with_index do |s, i|
        part = s.split("--").map(&:strip)
        part[0].to_i.must_equal(i)
        part[1].must_equal(@extracts[i].to_s)
      end

    end


    it "#decode " do
      selection = []
      (0...@extracts.size).each do |n|
        selection << n
        decoded = Extracts.decode(selection)
        decoded[:types].size.must_equal(selection.size)
        decoded[:types][n].must_be_instance_of(Symbol)
      end

      # [number selections] ~~> [extract symbols] ~~> decoded[:types]
      rand_numbers = (0...@extracts.size).to_a.sample(5) #numbers
      expected_extracts = rand_numbers.map{|i| @extracts[i].to_sym}
      decoded = Extracts.decode(rand_numbers)
      decoded[:types].sort.must_equal(expected_extracts.sort)
    end


    it "#assigned " do
      code = 0;
      (0...@extracts.size).each do |n|
        code += 2**n
        assigned = Extracts.assigned(code)
        assigned.must_be_instance_of(Array)
        assigned[0].must_be_instance_of(Symbol)
        assigned.size.must_equal(n+1)
      end

      # [extract symbols] ~~> bitwise code ~~> [assigned extract symbols]
      rand_extracts = @extracts.sample(5)
      code = rand_extracts.map{|n| @extracts.index(n)}.inject(0){|x,n| x+ 2**n}
      Extracts.assigned(code).sort.must_equal(rand_extracts.sort)
    end

  end

end



