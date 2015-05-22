module Metric::GroupableByTimeFrame
  extend ActiveSupport::Concern

  def group_by
    options.fetch(:group_by, :day).to_sym
  end
end
