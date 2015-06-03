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

  def reduce_by_users(data)
    data.each_with_object({}) do |(key, value), memo|
      next if value.zero?
      time_frame, user_id = key
      memo[time_frame] ||= Set.new
      memo[time_frame] << user_id
    end
  end
end
