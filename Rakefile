require "bundler/gem_tasks"
require 'rake/testtask'
begin
	require 'rdoc/task'
rescue LoadError
	require 'rake/rdoctask'
end
desc "Run unit tests"
Rake::TestTask.new("test_units") do |t|
	t.pattern = 'test/*_test.rb'
	t.verbose = true
	t.warning = true
end

desc "generate API documentation to doc/"
Rake::RDocTask.new do |rd|
	rd.rdoc_dir = 'doc/'
	rd.main = 'README.rdoc'
	rd.rdoc_files.include 'README.rdoc', 'MIT-LICENSE', 'lib/me2text/me2text.rb'

	rd.options << '-c utf-8'
	rd.options << '--inline-source'
	rd.options << '--line-numbers'
	rd.options << '--all'
	rd.options << '--fileboxes'
end

task :default => :test_units