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
    @start_date = attributes['start_date']
    @end_date   = attributes['end_date']

    @start_date = @start_date.nil? ? FAR_IN_PAST_DATE : Time.parse(@start_date)
    @end_date   = @end_date.nil? ? IN_FAR_FUTURE_DATE : Time.parse(@end_date)
  end
end
