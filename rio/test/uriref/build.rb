#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/rio/')
end
require 'pp'
require "test/unit"
require 'uriref'

class RIO::URIRef::BasicTest < Test::Unit::TestCase
  
  def setup
    super
  end
  
  def teardown
    super
  end

  def test_alturi_uriref_build
    alturi = Alt::URI::File.new
    u = RIO::URIRef.build(alturi)
    assert_kind_of(Alt::URI::Base,u.ref)
    assert_same(alturi,u.ref)
    assert_equal(alturi,u.ref)
  end

  def test_uriref_uriref_build
    alturi = Alt::URI::File.new
    ui = RIO::URIRef.build(alturi)
    u = RIO::URIRef.build(ui)
    assert_kind_of(Alt::URI::Base,u.ref)
    assert_same(alturi,u.ref)
    assert_equal(alturi,u.ref)
  end



end
