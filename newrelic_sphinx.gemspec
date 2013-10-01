# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "newrelic_sphinx"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Troels Knak-Nielsen"]
  s.date = "2013-10-01"
  s.description = "newrelic_sphinx is a plugin for new relic, pushing stats about your Sphinx server."
  s.email = ["troels@knak-nielsen.dk"]
  s.executables = ["sphinx_agent"]
  s.files = [
    "Rakefile",
    "VERSION",
    "bin/sphinx_agent",
    "lib/newrelic_sphinx/agent.rb",
    "newrelic_sphinx.gemspec"
  ]
  s.homepage = "http://github.com/troelskn/newrelic_sphinx"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.7"
  s.summary = "newrelic_sphinx is a plugin for new relic, pushing stats about your Sphinx server."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mysql2>, ["~> 0.3.13"])
    else
      s.add_dependency(%q<mysql2>, ["~> 0.3.13"])
    end
  else
    s.add_dependency(%q<mysql2>, ["~> 0.3.13"])
  end
end

