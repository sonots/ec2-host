# -*- coding: utf-8; -*-
# @license   Proprietary (DeNA domestic)

require 'bundler/setup'
Bundler.require :default
require 'bundler/dena/gem_tasks'

begin
  Bundler.require :development
  YARD::Rake::YardocTask.new
rescue LoadError, NameError
  # OK, they can be absent on non-development mode.
end

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
  require_relative "lib/dino-host"
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end
task :c => :console

desc "pry console"
task :pry do
  require_relative "lib/dino-host"
  require 'pry'
  ARGV.clear
  Pry.start
end

# 
# Local Variables:
# mode: ruby
# coding: utf-8
# indent-tabs-mode: nil
# tab-width: 8
# ruby-indent-level: 2
# fill-column: 79
# default-justification: full
# End:
# vi:ts=2:sw=2:
