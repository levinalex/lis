# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lis}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Levin Alexander"]
  s.date = %q{2010-02-07}
  s.default_executable = %q{lis}
  s.description = %q{}
  s.email = %q{mail@levinalex.net}
  s.executables = ["lis"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/lis",
     "features/communication basics.feature",
     "features/lis.feature",
     "features/step_definitions/lis_steps.rb",
     "features/support/env.rb",
     "lib/lis.rb",
     "lib/lis/application_protocol.rb",
     "lib/lis/io_listener.rb",
     "lib/lis/messages.rb",
     "lib/lis/packetized_protocol.rb",
     "lib/lis/worklist_manager_interface.rb",
     "lis.gemspec",
     "test/helper.rb",
     "test/lib/mock_server.rb",
     "test/test_io_listener.rb",
     "test/test_messages.rb",
     "test/test_packetized_protocol.rb"
  ]
  s.homepage = %q{http://github.com/levinalex/lis}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{LIS interface to Siemens Immulite 2000XPi or other similar analyzers}
  s.test_files = [
    "test/helper.rb",
     "test/lib/mock_server.rb",
     "test/test_io_listener.rb",
     "test/test_messages.rb",
     "test/test_packetized_protocol.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end
