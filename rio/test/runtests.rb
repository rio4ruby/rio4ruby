#!/usr/bin/ruby -KU
# encoding: UTF-8
Dir.chdir File.dirname(__FILE__)
$devlib=File.expand_path('../lib/')
$:.unshift $devlib unless $:[0] == $devlib
require 'platform'

require 'rio'
p "[#{RUBY_PLATFORM}] - Ruby(#{RUBY_VERSION}) - Rio(#{RIO::VERSION})"

$trace_states = false
require 'optparse'
require 'riotest/unit_test'


def get_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on("-f", "--ftp", "Run FTP Tests") do |v|
      options[:ftp] = v
    end
    opts.on("-h", "--http", "Run HTTP Tests") do |v|
      options[:http] = v
    end
    opts.on("-s", "--std", "Run Standard Tests") do |v|
      options[:std] = v
    end
    opts.on("-a", "--all", "Run All Tests") do |v|
      options[:std] = v
      options[:ftp] = v
      options[:http] = v
    end
  end.parse!
  
  options[:std] = true if options.empty?
  options
end
def find_tests(ms)
  self.class.constants.each do |cnst|
    cons = self.class.class_eval(cnst)
    if cons.kind_of?(Class) and cons.ancestors.include?(Test::Unit::TestCase)
      ms << cons.suite
    end
  end
  ms
end
def run(options)
  ms = RioTest::ModSuite.new("RIO")
  
  options.keys.each do |opt|
    case opt
    when :std
      require 'tc/all'
      require 'alturi/tests'
      require 'uriref/tests'
      find_tests(ms)
      ms.add(:URI,Alt)
      ms.add(:URIRef)
    when :http
      require 'http/tests'
      ms.add(:HTTP)
      #require 'lib/temp_server.rb'
      #TempServer.new.run('runhttptests.rb')
    when :ftp
      require 'ftp/tests'
      ms.add(:FTP)
    end
  end
  ms.run
end

options = get_options
run(options)

