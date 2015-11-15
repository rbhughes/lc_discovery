#this should match clowder/config/initializers/extracts_discovery.rb

types = %w(
  PROJECT
  WELL
  SURVEY
  FORMATION
  VECTOR
  RASTER
  VELOCITY
  LEGAL
  ZONE
  PRODUCTION
  FAULT
  CORE
  DST
  CASING
)

# Extracts represent datatypes that may be extracted from GeoGraphix projects.
# This Extracts module holds convenience methods for encoding/decoding extracts
# via bitwise comparison so that combinations can be serialized as an integer.
module Extracts

  module_function

  # accepts an array of number indexes for selected types,
  # returns a hash of types and sum of 2**n values (bit banging)
  # {:types =["PROJECT"], code => 1}
  def decode(nums)
    types = []
    sum = nums.map do |n|
      if (0...constants.size).to_a.include? n
        types << constants[n]
        const_get constants[n]
      end
    end.inject(:+)
    { types: types, code: sum }
  end

  # returns a formatted array of strings with integer and data type. e.g.
  # * 0 -- PROJECT
  # * 1 -- WELL
  # * 2 -- SURVEY
  # * 3 -- FORMATION
  # * 4 -- DIGITAL_CURVES
  # * etc...
  # The integers are used in command-line selections.
  def data_types_for_cli
    types = []
    constants.each_with_index do |type, i|
      types << format("%4s -- %-20s", i, type)
    end
    types
  end

  # Decode the extract number (integer) and return array of matching
  # data type as constant strings
  def assigned(code)
    types = []
    constants.each do |type|
      types << type if code & const_get(type) > 0 rescue 0
    end
    types
  end



end

  

# constants are defined here
types.each_with_index do |type, i|
  Extracts.const_set(type, 2**i)
end
