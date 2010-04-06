#!/usr/local/bin/ruby
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

module RioTest
  class TestSuite
    def self.build_suite(unit_test_mod)
      suite = Test::Unit::TestSuite.new(self.to_s)
      cons = unit_test_mod.constants
      p cons
      unit_test_mod.constants.each do |modstr|
        suite << unit_test_mod.module_eval(modstr).module_eval('TestCase').suite
      end
      return suite
    end
  end
  def test_suite_mod(mod,file)
    mod.module_eval do 
      ts = Class.new(RioTest::TestSuite)
      ts.class_eval do
        def self.suite
          build_suite(UnitTest)
        end
      end
      mod.const_set(:TestSuite,ts)
      ts
    end
    Test::Unit::UI::Console::TestRunner.run(mod.module_eval(:TestSuite))  if $0 == file
  end
  module_function :test_suite_mod
end


