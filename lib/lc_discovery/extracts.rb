types = %w(
  PROJ_META
  WELL
  SURVEY
  FORMATION
  DIGITAL_CURVES
  RASTER_CURVES
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
  # returns types and sum of 2**n values (bit banging)
  def sum_extracts(nums)
    types = []
    sum = nums.map do |n|
      if (0...self.constants.size).to_a.include? n
        types << self.constants[n]
        self.const_get self.constants[n]
      end
    end.inject(:+)
    {:types => types, :extracts => sum}
  end


  def extract_types
    types = []
    self.constants.each_with_index do |type,i|
      types << sprintf("%4s -- %-20s", i, type)
    end
    #types.join("\n")
    types
  end

  
  # decode the extract number and return array of types
  def assigned_extracts(extracts)
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

