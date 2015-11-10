require 'redis-objects'




class Person
  attr_reader :name
  alias :id :name

  include Redis::Objects

  def initialize name
    @name = name


  end

  FIELDS = [:age, :favorite_foods]

  FIELDS.each do |f|
    class_eval("def get_#{f}; self.#{f}.get; end")
  end


  def self.exists? name
    # Here's a big assumption, if the id attribute exists, the entire
    # object exists.  This might not work for your problem.
    self.redis.exists "name:{#name}:id"
  end

  def self.find name
    # new behaves like find when a record exists, so this works like
    # find_or_create()
    self.new name
  end


  

  # native redis attributes with redis-objects
  value :age
  list :favorite_foods

end



