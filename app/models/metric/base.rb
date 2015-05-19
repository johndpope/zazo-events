class Metric::Base
  attr_reader :group_by

  def initialize(options = {})
    @group_by = options.fetch(:group_by, :day).to_sym
  end

  def generate
  end
end
