require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'omniauth'
require 'omniauth-dropbox2'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.extend OmniAuth::Test::StrategyMacros, type: :strategy
  config.before(:each) do
    OmniAuth.config.test_mode = true
  end
  config.after(:each) do
    OmniAuth.config.test_mode = false
  end
end

WebMock.disable_net_connect!(allow_localhost: true)