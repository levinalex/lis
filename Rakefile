require 'rubygems'
require 'hoe'
require 'spec/rake/spectask'

require './lib/liaison_labor.rb'

Hoe.new('LiaisonLabor', LiaisonLabor::VERSION) do |p|
  p.rubyforge_name = 'liaison_labor'
  p.summary = 'interfaces Liaison device to worklist_manager'

  p.url = 'http://levinalex.net/src/liaison'
  p.developer('Levin Alexander', 'mail@levinalex.net')
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")

  # p.extra_deps ['levinalex-serial_interface']
end

Rake.application.instance_eval { @tasks["test"] = nil }

Spec::Rake::SpecTask.new do |t|
  t.warning = true
  t.spec_opts = %w(-c -f specdoc)
end
task :test => :spec

task :cultivate do
  system "touch Manifest.txt; rake check_manifest | grep -v \"(in \" | patch"
  system "rake debug_gem | grep -v \"(in \" > `basename \\`pwd\\``.gemspec"
end
