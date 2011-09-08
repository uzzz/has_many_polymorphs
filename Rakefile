require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'jeweler'

desc 'Run RSpec'
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

desc 'Generate documentation for the has_many_polymorphs plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Conductor'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Jeweler::Tasks.new do |gem|
  gem.name = 'has_many_polymorphs'
  gem.summary = %Q{An ActiveRecord plugin for self-referential and double-sided polymorphic associations.}
  gem.email = ['uzzable@gmail.com']
  gem.authors = ["Evan Weaver", "James Stewart", "Matthias Viehweger", "Max Zhylinski"]

  gem.add_dependency 'activerecord', '>= 3.1.0'
  gem.add_dependency 'activesupport', '>= 3.1.0'
end

task :default => :spec
