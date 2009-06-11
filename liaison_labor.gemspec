# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{LiaisonLabor}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Levin Alexander"]
  s.date = %q{2009-06-11}
  s.default_executable = %q{liaison_server}
  s.description = %q{An interface to the LIAISON® analyser by DiaSorin  <http://www.diasorin.com/en/productsandsystems/liaison>}
  s.email = ["mail@levinalex.net"]
  s.executables = ["liaison_server"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/liaison_server", "liaison_labor.gemspec", "lib/liaison_labor.rb", "lib/liaison_labor/interface.rb", "lib/liaison_labor/packets.rb", "lib/liaison_server.rb", "spec/liaison_interface_spec.rb", "spec/liaison_packet_spec.rb", "spec/mock/mock_liaison.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://levinalex.net/src/liaison}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{liaison_labor}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{interfaces Liaison device to worklist_manager}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.12.1"])
    else
      s.add_dependency(%q<hoe>, [">= 1.12.1"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.12.1"])
  end
end
