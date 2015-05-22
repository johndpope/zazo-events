class Metric::Base
  attr_reader :options
  
  def initialize(options = {})
    @options = options
  end

  def generate
  end
end
