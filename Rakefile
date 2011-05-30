$LOAD_PATH.unshift './lib'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'lis'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => [:test, :features]

