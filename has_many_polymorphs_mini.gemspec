# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_many_polymorphs_mini}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Max Zhilinsky"]
  s.date = %q{2011-09-06}
  s.description = %q{Foobar}
  s.email = ["uzzable@gmail.com"]
  s.files = [
    "Rakefile",
    "lib/has_many_polymorphs_mini.rb",
    "lib/has_many_polymorphs_mini/base.rb",
    "lib/has_many_polymorphs_mini/railtie.rb"
  ]
  s.homepage = %q{https://foobar}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Foobar}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["> 3.0.0"])
      s.add_runtime_dependency(%q<activesupport>, ["> 3.0.0"])
    else
      s.add_dependency(%q<activerecord>, ["> 3.0.0"])
      s.add_dependency(%q<activesupport>, ["> 3.0.0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["> 3.0.0"])
    s.add_dependency(%q<activesupport>, ["> 3.0.0"])
  end
end

