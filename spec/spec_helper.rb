ENV['RACK_ENV'] = 'test'
Bundler.require :test

# require 'simplecov'
# SimpleCov.start do
#   add_filter 'vendor/'
#   add_filter 'spec/'
#   add_group 'libs', 'lib'
# end

Bundler.require :default # <- need this *after* simplecov
require 'pry'
require 'ec2-host'
require 'dotenv'
Dotenv.load

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
end
