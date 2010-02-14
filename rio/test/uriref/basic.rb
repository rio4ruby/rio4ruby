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

  def test_initialize
    alturi = Alt::URI::File.new
    u = RIO::URIRef.new(alturi)
    assert_equal(alturi,u.ref)
    assert_nil(u.base)
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

  def test_starts_with_slash_slash_path_str_to_uri
    pth = "//ahost/a/b/c"
    u = RIO::URIRef.path_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal(pth,u.netpath)
    assert_equal("ahost",u.host)
    assert_equal("/a/b/c",u.path)
  end

  def test_starts_with_slash_path_str_to_uri
    pth = "/a/b/c"
    u = RIO::URIRef.path_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal(pth,u.path)
  end

  def test_starts_with_drive_path_str_to_uri
    pth = "C:/a/b/c"
    u = RIO::URIRef.path_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal(pth,u.path)
  end

  def test_starts_with_scheme_path_str_to_uri
    pth = "sc:/a/b/c"
    u = RIO::URIRef.path_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal('sc',u.scheme)
  end

  def test_starts_with_other_path_str_to_uri
    pth = "a/b/c"
    u = RIO::URIRef.path_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal(pth,u.path)
  end





  def test_starts_with_slash_slash_base_str_to_uri
    pth = "//ahost/a/b/c"
    u = RIO::URIRef.base_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal(pth,u.netpath)
    assert_equal('file',u.scheme)
    assert_equal("ahost",u.host)
    assert_equal("/a/b/c",u.path)
  end

  def test_starts_with_slash_base_str_to_uri
    pth = "/a/b/c"
    u = RIO::URIRef.base_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal('file',u.scheme)
    assert_equal('',u.authority)
    assert_equal(pth,u.path)
  end

  def test_starts_with_drive_base_str_to_uri
    pth = "C:/a/b/c"
    u = RIO::URIRef.base_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal('file',u.scheme)
    assert_equal('',u.authority)
    assert_equal(pth,u.path)
  end

  def test_starts_with_scheme_base_str_to_uri
    pth = "sc:/a/b/c"
    u = RIO::URIRef.base_str_to_uri(pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal('sc',u.scheme)
  end

  def test_starts_with_other_base_str_to_uri
    pth = "a/b/c"
    assert_raise(ArgumentError) {
      u = RIO::URIRef.base_str_to_uri(pth)
    }
  end

  def test_b_nil_abs
    alturi = Alt::URI::File.new
    ustr = 'b/c'
    bstr = 'file://host/a/d'
    u = RIO::URIRef.build(ustr,bstr)
    abs = u.abs
    assert_kind_of(RIO::URIRef,abs)
    assert_equal('file://host/a/b/c',abs.to_s)
    assert_equal(bstr,abs.base.to_s)
  end

  def test_b_not_nil_abs
    alturi = Alt::URI::File.new
    ustr = 'b/c'
    bstr = 'file://host/a/d'
    u = RIO::URIRef.build(ustr,bstr)
    sbase = 'http://ahost.com/x/y'
    abs = u.abs(sbase)
    assert_kind_of(RIO::URIRef,abs)
    assert_equal('http://ahost.com/x/b/c',abs.to_s)
    assert_equal(sbase,abs.base.to_s)
  end





  def test_b_nil_rel
    alturi = Alt::URI::File.new
    astr = 'file://host/a/b/c'
    rstr = 'b/c'
    bstr = 'file://host/a/d'
    u = RIO::URIRef.build(rstr,bstr)
    rel = u.rel
    assert_kind_of(RIO::URIRef,rel)
    assert_equal(rstr,rel.to_s)
    assert_equal(bstr,rel.base.to_s)
  end

  def test_b_not_nil_rel
    alturi = Alt::URI::File.new
    rstr = 'b/c'
    bstr = 'file://host/a/d'
    u = RIO::URIRef.build(rstr,bstr)
    sbase = 'http://ahost.com/x/y'
    abs = u.abs
    rel = u.rel(sbase)
    assert_kind_of(RIO::URIRef,rel)
    assert_equal(rstr,rel.to_s)
    assert_equal(sbase,rel.base.to_s)
  end

  def test_abs_rel
    astr = 'file://ahost/b/c/d'
    bstr = 'file://ahost/b/e/f'
    u = RIO::URIRef.build(astr,bstr)
    rel = u.rel
    assert_equal("../c/d",rel.to_s)
    u = RIO::URIRef.build(bstr,astr)
    rel = u.rel
    assert_equal("../e/f",rel.to_s)
  end



end
