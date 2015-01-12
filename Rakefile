require "bundler/gem_tasks"

task 'test' do
  Dir.chdir('test')
  system("rspec zanzibar_spec.rb")
end

task 'install_dependencies' do
  system('bundle install')
end
