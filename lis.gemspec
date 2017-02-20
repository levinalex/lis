# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'lis/version'

Gem::Specification.new do |s|
  s.name = %q{lis}
  s.version = LIS::VERSION

  s.authors = ["Levin Alexander"]
  s.description = %q{}
  s.email = %q{mail@levinalex.net}
  s.license = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.homepage = %q{http://github.com/levinalex/lis}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{LIS interface to Siemens Immulite 2000XPi or other similar analyzers}

  s.add_dependency "packet_io", "~> 0.4.3"
  s.add_dependency "httparty", "~> 0.14.0"
  s.add_dependency "rake", "~> 12.0.0"
  s.add_dependency "main", "~> 6.2.2"
  s.add_dependency "json", "~> 2.0.3"

  s.add_development_dependency("shoulda-context", "~> 1.2.2")
  s.add_development_dependency("mocha", "~> 1.2.1")
  s.add_development_dependency("yard", "~> 0.9.8")
  s.add_development_dependency("cucumber", "~> 2.4.0")
  s.add_development_dependency("webmock", "~> 2.3.2")
  s.add_development_dependency("aruba", "~> 0.14.2")
  s.add_development_dependency("test-unit", "~> 3.2.3" )
end

