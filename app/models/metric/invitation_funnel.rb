class Metric::InvitationFunnel < Metric::Base
  FAR_IN_PAST_DATE   = 10.years.ago
  IN_FAR_FUTURE_DATE = 10.years.from_now

  after_initialize :set_attributes

  attr_accessor :start_date, :end_date

  def self.type
    :invitation_funnel
  end

  def generate
    [ :verified_sent_invitations,
      :average_invitations_count,
      :invited_to_registered,
      :registered_to_verified,
      :verified_to_active
    ].each_with_object({}) do |metric, memo|
      klass = "Metric::InvitationFunnel::#{metric.to_s.camelize}".constantize
      memo[metric] = klass.new(start_date, end_date).generate
    end
  end

  private

  def set_attributes
    @start_date = get_attribute_value 'start_date'
    @end_date   = get_attribute_value 'end_date'
  end

  def get_attribute_value(variable)
    Time.parse attributes[variable]
  rescue ArgumentError, TypeError
    default_attribute_value variable
  end

  def default_attribute_value(attr)
    case attr
      when 'start_date' then FAR_IN_PAST_DATE
      when 'end_date'   then IN_FAR_FUTURE_DATE
      else FAR_IN_PAST_DATE
    end
  end
end
