#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require 'pp'
require "test/unit"
require 'rio/uriref'

class RIO::URIRef::RouteTest < Test::Unit::TestCase
  
  def setup
    super
  end
  
  def teardown
    super
  end

  def test_rf_file
    a_s = "file://ahost/a/"
    extra_s = 'b/c'
    c_s = a_s + extra_s

    u_a = ::Alt::URI.parse(a_s)
    u_extra = ::Alt::URI.parse(extra_s)
    u_c = ::Alt::URI.parse(c_s)

    a = RIO::URIRef.new(u_a,u_a)
    c = RIO::URIRef.new(u_c,u_c)
    extra = RIO::URIRef.new(u_extra,u_a)


    rf = c.route_from(a)
    assert_equal(extra.to_s,rf.to_s)

    rf_abs = rf.abs
    rf_abs_s = rf_abs.to_s
    assert_equal(c_s,rf_abs_s)
  end

  def test_file_build_route_from
    a_s = "file://ahost/a/"
    extra_s = 'b/c'
    c_s = a_s + extra_s

    a = RIO::URIRef.build(a_s)
    c = RIO::URIRef.build(c_s)
    extra = RIO::URIRef.build(extra_s,a_s)
    
    rf = c.route_from(a)
    assert_kind_of(RIO::URIRef,rf)
    assert_kind_of(::Alt::URI::Base,rf.ref)
    assert_equal(extra_s,rf.to_s)
    assert_kind_of(::Alt::URI::Base,rf.base)
    assert_equal(a.ref,rf.base)
    assert_equal(c,rf.abs)
  end

  def test_file_build_route_to
    a_s = "file://ahost/a/"
    extra_s = 'b/c'
    c_s = a_s + extra_s

    a = RIO::URIRef.build(a_s)
    c = RIO::URIRef.build(c_s)
    extra = RIO::URIRef.build(extra_s,a_s)
    
    rf = a.route_to(c)
    assert_kind_of(RIO::URIRef,rf)
    assert_kind_of(::Alt::URI::Base,rf.ref)
    assert_equal(extra_s,rf.to_s)
    assert_kind_of(::Alt::URI::Base,rf.base)
    assert_equal(a.ref,rf.base)
    assert_equal(c,rf.abs)
  end

end
