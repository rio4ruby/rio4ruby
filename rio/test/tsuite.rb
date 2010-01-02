Dir.chdir File.dirname(__FILE__)
$devlib=File.expand_path('../lib/')
$:.unshift $devlib unless $:[0] == $devlib
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'
require 'tc/closeoneof'
$trace_states = true

class Tsuite
    def self.suite
        suite = Test::Unit::TestSuite.new("TSuite")
        suite << TC_RIO_closeoneof.suite
        return suite
    end
end

#Test::Unit::UI::Tk::TestRunner.run(Tsuite)
Test::Unit::UI::Console::TestRunner.run(Tsuite)

