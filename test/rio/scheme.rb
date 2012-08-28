#!/usr/local/bin/ruby
if $0 == __FILE__
  $:.unshift File.expand_path(File.dirname(__FILE__))
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require 'rio'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'tc/pathparts.rb'

module RIO
  module TestCase
    TEST_TOP = '/loc/work/q/test'
  end
end

module RIO
  module TestCase
    module UnitTest
      def run_tests(test_dir,test_top = TEST_TOP,&block)
        rio(test_top).mkdir.chdir do
          rio(test_dir).delete!.mkdir.chdir do
            yield
          end
        end
      end
    end
  end
end


class TC_scheme < Test::Unit::TestCase
  include RIO::TC::Scheme
end
class TC_host < Test::Unit::TestCase
  include RIO::TC::Host
end

class TS_PathPartsTests
  def self.suite
    suite = Test::Unit::TestSuite.new("PathParts Tests")
    suite << TC_scheme.suite
    suite << TC_host.suite
    return suite
  end
end
Test::Unit::UI::Console::TestRunner.run(TS_PathPartsTests)

