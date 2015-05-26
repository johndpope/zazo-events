class Metric::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  attr_reader :attributes

  define_model_callbacks :initialize

  def self.metric_name
    name.demodulize.underscore
  end

  def self.type
    :metric
  end

  def self.to_hash
    { name: name, metric_name: metric_name, type: type }
  end

  def initialize(attributes = {})
    run_callbacks :initialize do
      @attributes = attributes.stringify_keys
    end
  end

  def generate
  end
end
