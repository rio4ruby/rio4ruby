#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)
  $:.unshift File.expand_path('../lib/')
end
$mswin32 = (RUBY_PLATFORM =~ /mswin32/)
$jruby = (RUBY_PLATFORM =~ /java/)

require 'rio/version'
p "[#{RUBY_PLATFORM}] - Ruby(#{RUBY_VERSION}) - Rio(#{RIO::VERSION})"

require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require 'alturi/test_suite'
require 'uriref/test_suite'

class RIO::TestSuite
    def self.suite
        suite = Test::Unit::TestSuite.new("RIO::TestSuite")
        #suite << RIO::URIRef::TestSuite.suite
        suite << Alt::URI::TestSuite.suite
        #suite << RIO::TC::TestSuite.suite
        return suite
    end
end


Test::Unit::UI::Console::TestRunner.run(RIO::TestSuite) if $0 == __FILE__


