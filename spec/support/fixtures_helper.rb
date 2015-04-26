module FixturesHelper
  def json_fixture(path)
    file_path = File.join(RSpec.configuration.fixture_path, "#{path.gsub('.json', '')}.json")
    ActiveSupport::JSON.decode File.read(file_path)
  end
end

RSpec.configure do |config|
  config.include FixturesHelper
end
