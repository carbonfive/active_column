# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_column/version"

Gem::Specification.new do |s|
  s.name        = "active_column"
  s.version     = ActiveColumn::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Wynholds"]
  s.email       = ["mike@wynholds.com"]
  s.homepage    = "https://github.com/carbonfive/active_column"
  s.summary     = %q{Provides time line support and database migrations for Cassandra}
  s.description = %q{Provides time line support and database migrations for Cassandra}

  s.rubyforge_project = "active_column"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "lib/active_column/types"]

  s.add_dependency 'cassandra', '>= 0.12'
  s.add_dependency 'simple_uuid', '~> 0.2.0'
  s.add_dependency 'rake'

  s.add_development_dependency 'rails', '>= 3.0'
  s.add_development_dependency 'rspec-rails', '>= 2.5.0'
  s.add_development_dependency 'wrong'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'bluecloth'
  s.add_development_dependency 'mocha'
end
