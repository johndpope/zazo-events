class Metric::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  attr_reader :attributes

  define_model_callbacks :initialize

  def self.metric_name
    name.demodulize.underscore
  end

  def self.type
    :aggregated
  end

  def self.to_hash
    { name: metric_name, type: type }
  end

  def initialize(attributes = {})
    run_callbacks :initialize do
      @attributes = attributes.stringify_keys
    end
  end

  def generate
  end
end
