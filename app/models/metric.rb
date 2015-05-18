module Metric
  class UnknownMetric < StandardError
  end

  def self.build(name)
    klass = name.to_s.classify
    begin
      const_get(klass)
    rescue NameError
      raise UnknownMetric, "Metric #{name.inspect} not found"
    end
  end
end
