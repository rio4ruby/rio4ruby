#!/usr/bin/ruby
Dir.chdir File.dirname(__FILE__)
$devlib=File.expand_path('../lib/')
$:.unshift $devlib unless $:[0] == $devlib

require 'rio'
require 'test/unit'

require 'tc/all'
$trace_states = false
require 'test/unit/ui/console/testrunner'
#require 'test/unit/ui/tk/testrunner'
