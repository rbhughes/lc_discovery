require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"
require 'mocha/mini_test'
require_relative "../lib/lc_discovery/discovery"

describe Discovery do


  before do
    @opts = {
      project: File.expand_path("../../support/sample", __FILE__),
      label: "fakery"
    }

    #@fake = {
    #  wellheader: [
    #    {:"well id" => "111", longitude: -122.0, latitude: 37.6},
    #    {:"well id" => "222", longitude: -122.2, latitude: 37.4},
    #    {:"well id" => "333", longitude: -222.1, latitude: 27.5},
    #    {:"well id" => "444", longitude: -122.2, latitude: 97.5},
    #    {:"well id" => "555", longitude:  nil, latitude: 37.5}
    #  ]
    #}
    #@mini_bulk = 3

    #@xtract = WellExtractor.new(@opts)
    #@xtract.gxdb[:wellheader].multi_insert(@fake[:wellheader])
  end

  #after do
    #@xtract.gxdb[:wellheader].delete
  #end


  

  describe "when initialized with a project gxdb connection" do

    it "does stuff" do
      puts Discovery::Sybase
    end

  end

  describe "when various module methods are called" do

    it "does other stuff" do
      puts Discovery::Sybase
    end

  end

end


