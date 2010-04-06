#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/rio/')
end
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require 'uriref/basic'
require 'uriref/build'
require 'uriref/route'

class RIO::URIRef::TestSuite
    def self.suite
        suite = Test::Unit::TestSuite.new("RIO::URIRef::TestSuite")
        suite << RIO::URIRef::BasicTest.suite
        suite << RIO::URIRef::BuildTest.suite
        suite << RIO::URIRef::RouteTest.suite
        return suite
    end
end


Test::Unit::UI::Console::TestRunner.run(RIO::URIRef::TestSuite)  if $0 == __FILE__


