module Metric::Filter
  extend ActiveSupport::Concern

  included do
    def self.type
      :filter
    end
  end
end
