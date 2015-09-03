module DateTimeFormat
  def format_datetime(time_instance)
    time_instance.strftime '%Y-%m-%d %H:%M:%S'
  end
end

RSpec.configure do |config|
  config.include DateTimeFormat
end
