#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'rio/uriref'
require 'uriref/tc/basic'
require 'uriref/tc/build'
require 'uriref/tc/route'

require 'riotest/unit_test.rb'


RioTest::ModSuite.new(:URIRef).run if $0 == __FILE__
