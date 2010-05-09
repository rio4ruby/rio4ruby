#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'ftp/tc/anon_read'
require 'ftp/tc/anon_copy_data'
require 'ftp/tc/anon_misc'
require 'ftp/tc/anon_special'
require 'ftp/tc/anon_write'
require 'ftp/tc/ftp2ftp'
require 'ftp/tc/ftp_fs'

require 'test/unit'

mods = RIO::FTP::UnitTest.constants
p mods

mods.each do |modstr|
  RIO::FTP::UnitTest.module_eval(modstr).module_eval do 
    class TestCase < Test::Unit::TestCase
      include Tests
    end
  end
end

#module RIO::FTP::UnitTest
#  module AnonRead
#    
#    class TestCase < Test::Unit::TestCase
#      include Tests
#    end
#
#  end
#end

