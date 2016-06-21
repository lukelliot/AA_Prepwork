class Temperature
  attr_accessor :fahrenheit, :celsius

  def initialize(options)
    if options[:f]
      self.fahrenheit = options[:f]
    else
      self.celsius = options[:c]
    end
  end

  def fahrenheit=(temperature)
    @temperature = self.class.ftoc(temperature)
  end

  def celsius=(temperature)
    @temperature = temperature
  end
  # ^Write methods for fahrenheit and celsius
  # they take precedence over attr_accessor

  #-------------------------------------#

  def self.ftoc(f)
    (f - 32) * (5.0 / 9.0)
  end

  def self.ctof(c)
    (c * (9.0 / 5.0)) + 32
  end
  # ^Class Methods for taking input and
  # converting to opposite standard

  #-------------------------------------#

  def in_fahrenheit
    self.class.ctof(@temperature)
  end

  def in_celsius
    @temperature
  end
  # ^Return stored temperature in specified standard

  #-------------------------------------#
  def self.from_fahrenheit(temperature)
    self.new(f: temperature)
  end

  def self.from_celsius(temperature)
    self.new(c: temperature)
  end
  # ^Factory Methods

end

class Celsius < Temperature
  def initialize(temperature)
    @temperature = temperature
  end
end

class Fahrenheit < Temperature
  def initialize(temperature)
    @temperature = self.class.ftoc(temperature)
  end
end
