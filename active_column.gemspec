# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_column/version"

Gem::Specification.new do |s|
  s.name        = "active_column"
  s.version     = ActiveColumn::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Wynholds"]
  s.email       = ["mike@carbonfive.com"]
  s.homepage    = "http://rubygems.org/gems/active_column"
  s.summary     = %q{Provides time line support for Cassandra}
  s.description = %q{Provides time line support for Cassandra}

  s.rubyforge_project = "active_column"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'simple_uuid'

  s.add_development_dependency 'cassandra'
  s.add_development_dependency 'rspec'
end
