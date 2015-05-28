module Metric::GroupableByTimeFrame
  extend ActiveSupport::Concern

  attr_accessor :group_by

  included do
    validates :group_by, presence: true,
                         inclusion: { in: Groupdate::FIELDS,
                                      message: "is not included in #{Groupdate::FIELDS}" }
    after_initialize :set_group_by
  end

  module ClassMethods
    def type
      :aggregated_by_timeframe
    end
  end

  protected

  def set_group_by
    @group_by = attributes.fetch('group_by', :day).try(:to_sym)
  end
end
