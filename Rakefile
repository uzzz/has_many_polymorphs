require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'jeweler'

desc 'Run RSpec'
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

desc 'Generate documentation for the conductor plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Conductor'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Jeweler::Tasks.new do |gem|
  gem.name = 'has_many_polymorphs_mini'
  gem.summary = %Q{Foobar}
  gem.description = %Q{Foobar}
  gem.email = ['uzzable@gmail.com']
  gem.homepage = 'https://foobar'
  gem.authors = ['Max Zhilinsky']

  gem.add_dependency 'activerecord', '> 3.0.0'
  gem.add_dependency 'activesupport', '> 3.0.0'
end

task :default => :spec
