# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'lis/version'

Gem::Specification.new do |s|
  s.name = %q{lis}
  s.version = LIS::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Levin Alexander"]
  s.description = %q{}
  s.email = %q{mail@levinalex.net}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.homepage = %q{http://github.com/levinalex/lis}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{LIS interface to Siemens Immulite 2000XPi or other similar analyzers}

  s.add_dependency "packet_io", "~> 0.4.0.rc2"

  s.add_development_dependency("shoulda", ["~> 2.11.3"])
  s.add_development_dependency("mocha", ["~> 0.9.12"])
  s.add_development_dependency("yard", ["~> 0.7.1"])
  s.add_development_dependency("cucumber", ["~> 0.10.3"])
end

