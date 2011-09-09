# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_many_polymorphs}
  s.summary = %q{An ActiveRecord plugin for self-referential and double-sided polymorphic associations.}
  s.version = "1.0.0"

  s.required_rubygems_version = ">= 1.3.6"

  s.authors = ["Evan Weaver", "James Stewart", "Matthias Viehweger", "Max Zhylinski"]
  s.email = ["uzzable@gmail.com"]
  s.date = %q{2011-09-08}
  s.files = Dir.glob("lib/**/*") + [
    ".rspec",
    "Gemfile",
    "Rakefile",
    "spec/database.yml",
    "spec/has_many_polymorphs/has_many_polymorphs_spec.rb",
    "spec/models.rb",
    "spec/schema.rb",
    "spec/spec_helper.rb"
  ]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}

  s.add_runtime_dependency(%q<rails>, [">= 3.1.0"])
  s.add_runtime_dependency(%q<activerecord>, [">= 3.1.0"])
  s.add_runtime_dependency(%q<activesupport>, [">= 3.1.0"])
  s.add_development_dependency(%q<rspec>, ["> 2.0.0"])
  s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
end

