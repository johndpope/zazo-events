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

  def self.all
    Metric::Base.descendants.select { |klass| klass.name.starts_with?("#{name}::") }.sort_by(&:name)
  end
end
