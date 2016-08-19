require 'performance_test/performance_test_runner'
# see https://relishapp.com/rspec/rspec-expectations/docs/syntax-configuration
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

