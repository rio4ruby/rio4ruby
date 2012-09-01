#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rdoc/task"

Rake::RDocTask.new do |rdoc|
  # $:.unshift File.expand_path(File.dirname(__FILE__))

  # p File.dirname(__FILE__) + '/../'
  # p $:
  require 'rdoc/rdoc'
  # require 'rdoc/generator/parts'
  rdoc.main = 'RIO::Doc::SYNOPSIS'
  rdoc.rdoc_files.include("README", 
                          "lib/rio.rb", 
                          "lib/rio/doc/*.rb",
                          "lib/rio/if/*.rb",
                          "lib/rio/kernel.rb",
                          "lib/rio/constructor.rb")

  # #p $:[0]
  # rdoc.rdoc_dir = 'doc'
  # rdoc.title    = PKG::TITLE
  # rdoc.options = PKG::RDOC_OPTIONS + ['--format=parts']
  # rdoc.inline_source = false
  #rdoc.show_hash = true
  #rdoc.add_generator(RDoc::Generator::Riofish)
  #PKG::FILES::DOC.to_a.each do |glb|
  #  #next if glb =~ /yaml.rb$/
  #  rdoc.rdoc_files.include( glb )
  #end
  #rdoc.template = 'doc/generators/template/html/rio.rb'
end

namespace :development do
  gemspec = eval(::File.open(Dir[File.join(::File.dirname(__FILE__), "{,*}.gemspec")].first).read)
  gemname = "#{gemspec.name}-#{gemspec.version}.gem"
  desc "Release #{gemname} to private gem server"
  task :release_private, [:host,:remote_dir] => :build do |t,args|
    args.with_defaults(:host => 'gems', :remote_dir => '/srv/www/gems')
    puts "Releasing #{gemname} to gem server at '#{args[:host]}' using remote directory '#{args[:remote_dir]}'"
    sh %{scp pkg/#{gemname} #{args[:host]}:#{args[:remote_dir]}/gems} do |ok, res|
      if ok 
        sh %{ ssh #{args[:host]} 'bash -l -c "gem generate_index -d #{args[:remote_dir]}"'  } do |ok, res|
          puts "command failed with status '#{res.exitstatus}'" unless ok
        end
      else
        puts "command failed with status '#{res.exitstatus}'"
      end
    end
  end
end

