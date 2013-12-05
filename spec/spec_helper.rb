require 'screenpress'

RSpec.configure do |config|
  config.mock_framework = :rspec
  
  config.include Screenpress::DSL

  config.after(:each) do
    Screenpress.send(:reset)
  end

end