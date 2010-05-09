#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'uriref/tc/basic'
require 'uriref/tc/build'
require 'uriref/tc/route'

require 'test/unit'
require 'riotest/unit_test.rb'

RioTest.define_utmod(:URIRef)

