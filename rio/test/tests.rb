#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)
  $:.unshift File.expand_path('../lib/')
end

require 'rio'

require 'test/unit'
require 'riotest/unit_test.rb'

require 'ftp/tests'
#p Dir.getwd
require 'http/tests'
#p Dir.getwd
require 'alturi/tests'
require 'uriref/tests'


ms = RioTest::ModSuite.new("RIO")
ms.add(:FTP)
ms.add(:HTTP)
ms.add(:URI,Alt)
ms.add(:URIRef)
ms.run

#suite = Test::Unit::TestSuite.new("RIO")

#suite << RioTest::ModSuite.new(:FTP).suite
#suite << RioTest::ModSuite.new(:HTTP).suite

#Test::Unit::UI::Console::TestRunner.run(suite)
