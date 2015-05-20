module Metric
  class UnknownMetric < StandardError
  end

  def self.find(name)
    klass = name.to_s.camelize
    begin
      const_get(klass)
    rescue NameError
      raise UnknownMetric, "Metric #{name.inspect} not found"
    end
  end
end
