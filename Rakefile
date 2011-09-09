require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'rdoc/task'

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

task :default => :spec
