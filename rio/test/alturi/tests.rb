#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'rio/alturi'
require 'alturi/tc/create'
require 'alturi/tc/file_test'
require 'alturi/tc/ftp_alturi'
require 'alturi/tc/generic_test'
require 'alturi/tc/http_test'
require 'alturi/tc/path_parts_test'
require 'alturi/tc/rfc_test'
require 'alturi/tc/uri_parts_authority'
require 'alturi/tc/uri_parts_test'
require 'alturi/tc/uri_parts_userinfo'

require 'riotest/unit_test.rb'


RioTest::ModSuite.new(:URI,Alt).run if $0 == __FILE__

#RioTest.define_utmod(:URI,Alt)

