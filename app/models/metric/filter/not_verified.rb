class Metric::Filter::NotVerified < Metric::Base
  include Metric::Filter

  def generate
    Metric::Filter::NotVerified.type
  end
end
