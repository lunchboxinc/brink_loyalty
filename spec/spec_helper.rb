require 'rspec'
require 'webmock/rspec'
require 'bundler/setup'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f } 
ENV['RAILS_ENV'] = 'test' 
require_relative '../spec/dummy/config/environment' 
ENV['RAILS_ROOT'] ||= "#{File.dirname(__FILE__)}../../../spec/dummy" 

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end