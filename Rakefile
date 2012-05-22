require "bundler/gem_tasks"
require 'rake/testtask'

desc "Run unit tests"
Rake::TestTask.new("test_units") do |t|
	t.pattern = 'test/*_test.rb'
	t.verbose = true
	t.warning = true
end

task :default => :test_units