#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)
$:.unshift File.expand_path('../lib/')
$:.unshift File.expand_path('../test/')

require 'rio'
p "[#{RUBY_PLATFORM}] - Ruby(#{RUBY_VERSION}) - Rio(#{RIO::VERSION})"
require 'lib/temp_server'
require 'pp'

runtestpath = File.expand_path('runhttptests.rb')
TempServer.run(runtestpath)

#threads.each { |aThread|  aThread.join }
