require_relative 'lib/ec2/host/version'

Gem::Specification.new do |gem|
  gem.name          = "ec2-host"
  gem.version       = EC2::Host::VERSION
  gem.author        = ['Naotoshi Seo']
  gem.email         = ['sonots@gmail.com']
  gem.homepage      = 'https://github.com/sonots/ec2-host'
  gem.summary       = "Search hosts on AWS EC2"
  gem.description   = "Search hosts on AWS EC2"
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.bindir        = "exe"
  gem.executables   = `git ls-files -- exe/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'aws-sdk-ec2'
  gem.add_runtime_dependency 'dotenv'
  gem.add_runtime_dependency 'inifile'

  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rdoc'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
end
