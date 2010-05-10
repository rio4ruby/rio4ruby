#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
  $:.unshift File.expand_path('../test/')
end

require 'rio'
module RIO
  module HTTP
  end
end

require 'http/tc/uri_meta.rb'
require 'http/tc/copy_from_http.rb'

require 'riotest/unit_test'

RioTest::ModSuite.new(:HTTP).run if $0 == __FILE__
