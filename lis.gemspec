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

  s.add_dependency "packet_io", ">= 0.4.2"
  s.add_dependency "rest-client"
  s.add_dependency "rake"
  s.add_dependency "gli", ">= 2.0.0.rc5"

  s.add_development_dependency("shoulda", ">= 3.1.0")
  s.add_development_dependency("mocha", ">= 0.12.0")
  s.add_development_dependency("yard")
  s.add_development_dependency("cucumber", ">= 1.2.0")
  s.add_development_dependency("webmock", ">= 1.8.7")
  s.add_development_dependency('aruba')
end

