require 'rubygems'

Gem::Specification.new do |gem|
  gem.name                  = "ec2-host"
  gem.version               = '0.0.1'
  gem.author                = ['Naotoshi Seo']
  gem.homepage              = 'https://github.com/sonots/ec2-host'
  gem.license               = 'MIT'
  gem.files                 = Dir.glob ['{lib,models}/**/*.rb', 'README.md']
  gem.summary               = "Get hosts on aws ec2 environment"
  gem.description           = "Get hosts on aws ec2 environment"

  gem.add_runtime_dependency 'aws-sdk'
  gem.add_runtime_dependency 'hashie'

  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rdoc'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'dotenv'
end
