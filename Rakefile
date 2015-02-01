require 'bundler/gem_tasks'
require 'bundler/setup' # load up our gem environment (incl. local zanzibar)
require 'rspec/core/rake_task'
require 'zanzibar/version'
require 'rubocop/rake_task'

task default: [:test]

RSpec::Core::RakeTask.new(:test)

RuboCop::RakeTask.new
