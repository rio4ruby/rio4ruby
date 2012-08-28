#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'ftp/tc/anon_read'
require 'ftp/tc/anon_copy_data'
require 'ftp/tc/anon_misc'
require 'ftp/tc/anon_special'
require 'ftp/tc/anon_write'
require 'ftp/tc/ftp2ftp'
require 'ftp/tc/ftp_fs'

require 'riotest/unit_test.rb'
require 'riotest/util'

RioTest::ModSuite.new(:FTP).run if $0 == __FILE__

#wdir = File.expand_path('qp/ftp')
#rio(wdir).delete!.mkpath.chdir do
#  RioTest.define_utmod(:FTP)
#end
