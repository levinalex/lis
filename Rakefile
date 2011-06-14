$LOAD_PATH.unshift './lib'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'lis'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

require 'yard'
YARD::Rake::YardocTask.new

task :doc => :yard
task :default => [:test, :features]
