# -*- coding: utf-8; -*-
require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new :spec do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end
  task default: :spec
rescue LoadError, NameError
  # OK, they can be absent on non-development mode.
end

desc "irb console"
task :console do
  require_relative "lib/ec2-host"
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end
task :c => :console

desc "pry console"
task :pry do
  require_relative "lib/ec2-host"
  require 'pry'
  ARGV.clear
  Pry.start
end
