class Metric::InvitationFunnel::Base
  attr_reader :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date   = end_date
  end

  def generate
    Hash.new
  end

  protected

  def query(sql)
    Event.connection.select_all sql
  end

  def query_first(sql)
    query(sql)[0]
  end

  def default_if_nil(data)
    data ? data : default_data.stringify_keys
  end

  def default_if_key_nil(data, key)
    data[key.to_s] ? data : default_data.stringify_keys
  end

  def default_data
    Hash.new
  end
end
