#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
module RIO
  module HTTP
  end
end




require 'http/tc/uri_meta.rb'
require 'http/tc/copy_from_http.rb'

require 'test/unit'
require 'riotest/unit_test.rb'



wdir = File.expand_path('qp/http')
rio(wdir).delete!.mkpath.chdir do
  RioTest.define_utmod(:HTTP)
end
