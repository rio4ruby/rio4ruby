#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/rio/')
end

require 'alturi/create'
require 'alturi/rfc_test'
require 'alturi/generic_test'
#require 'alturi/http_test'
#require 'alturi/path_parts_test'
#require 'alturi/uri_parts_test'
#require 'alturi/rfc_test'
#require 'alturi/file_test'

require 'riotest/test_suite'

RioTest.test_suite_mod(Alt::URI,__FILE__)




