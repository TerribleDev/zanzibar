require 'bundler/gem_tasks'
require 'bundler/setup' # load up our gem environment (incl. local zanzibar)
require 'rspec/core/rake_task'
require 'zanzibar/version'
require 'rubocop/rake_task'

task default: [:test]

RSpec::Core::RakeTask.new(:test)
RuboCop::RakeTask.new

task :cc_local do
  command =  'docker run '
  command << '--interactive --tty --rm '
  command << '--env CODECLIMATE_CODE="$PWD" '
  command << '--volume "$PWD":/code '
  command << '--volume /var/run/docker.sock:/var/run/docker.sock '
  command << '--volume /tmp/cc:/tmp/cc '
  command << 'codeclimate/codeclimate analyze'
  sh command
end
