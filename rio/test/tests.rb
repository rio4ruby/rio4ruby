#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)
  $:.unshift File.expand_path('../lib/')
end

require 'rio'

#require 'test/unit'
require 'riotest/unit_test.rb'

require 'ftp/tests'
require 'http/tests'
require 'alturi/tests'
require 'uriref/tests'

require 'tc/all.rb'

ms = RioTest::ModSuite.new("RIO")
ms.add(:FTP)
ms.add(:HTTP)
ms.add(:URI,Alt)
ms.add(:URIRef)

def find_tests(ms)
  self.class.constants.each do |cnst|
    cons = self.class.class_eval(cnst)
    if cons.kind_of?(Class) and cons.ancestors.include?(Test::Unit::TestCase)
      ms << cons.suite
    end
  end
  ms
end
find_tests(ms)
ms.run
