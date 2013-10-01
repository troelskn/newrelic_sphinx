# -*- coding: utf-8 -*-
begin
  require 'jeweler'
  #require 'rubygems'
  #gem :jeweler
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "newrelic_sphinx"
    gemspec.summary = "newrelic_sphinx is a plugin for new relic, pushing stats about your Sphinx server."
    gemspec.email = ["troels@knak-nielsen.dk"]
    gemspec.homepage = "http://github.com/troelskn/newrelic_sphinx"
    gemspec.description = gemspec.summary
    gemspec.authors = ["Troels Knak-Nielsen"]
    gemspec.license = 'MIT'
    gemspec.add_dependency 'mysql2', ['~> 0.3.13']
    gemspec.files.include = 'lib/**/*.rb'
    gemspec.files.include = 'bin/**/*'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => err
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
  p err
end

desc "Generates API documentation"
task :rdoc do
  sh "rm -rf doc && rdoc lib"
end

task :default do
  puts "Run `rake version:bump:patch release`"
end

