types = %w(
  META
  WELL
  SURVEY
  FORMATION
  DIGITAL_CURVE
  RASTER_CURVE
  VELOCITY
  LEGAL
  ZONE
  PRODUCTION
  FAULT
  CORE
  DST
  CASING
)

module Extracts

  module_function
  
  # accepts an array of number indexes for selected types,
  # returns a hash of types and sum of 2**n values (bit banging)
  # {:types =["PROJ_META"], code => 1}
  def decode(nums)
    types = []
    sum = nums.map do |n|
      if (0...self.constants.size).to_a.include? n
        types << self.constants[n]
        self.const_get self.constants[n]
      end
    end.inject(:+)
    {:types => types, :code => sum}
  end


  # returns a formatted array of strings with integer and data type. e.g.
  # 0 -- PROJ_META
  # 1 -- WELL
  # 2 -- SURVEY
  # 3 -- FORMATION
  # 4 -- DIGITAL_CURVES
  # The integers are used in command-line selections.
  def data_types
    types = []
    self.constants.each_with_index do |type,i|
      types << sprintf("%4s -- %-20s", i, type)
    end
    types
  end

  
  # decode the extract number (integer) and return array of matching 
  # data type strings from above
  def assigned(extracts)
    types = []
    self.constants.each do |type|
      types << type if (extracts & self.const_get(type) > 0)
    end
    types
  end

end

#constants are defined here
types.each_with_index do |type,i|
  Extracts.const_set(type, 2**i)
end

