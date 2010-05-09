#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)
  $:.unshift File.expand_path('../lib/')
end

require 'rio'

require 'test/unit'
require 'riotest/unit_test.rb'

require 'ftp/tests'
p Dir.getwd
require 'http/tests'
p Dir.getwd
require 'alturi/tests'
require 'uriref/tests'
