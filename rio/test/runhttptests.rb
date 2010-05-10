Dir.chdir File.dirname(__FILE__)
$devlib=File.expand_path('../lib/')
$:.unshift $devlib unless $:[0] == $devlib

$mswin32 = (RUBY_PLATFORM =~ /mswin32/)

require 'rio'
require 'test/unit'

require 'http/tests'


RioTest::ModSuite.new(:HTTP).run if $0 == __FILE__
