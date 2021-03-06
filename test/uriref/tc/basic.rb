require 'rio'
require 'rio/uriref'

module RIO::URIRef::UnitTest
  module Basic
    module Tests


  def test_initialize
    alturi = Alt::URI::File.new
    u = RIO::URIRef.new(alturi)
    assert_equal(alturi,u.ref)
    assert_nil(u.base)
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
    u = RIO::URIRef.build(ustr,:base => bstr)
    abs = u.abs
    assert_kind_of(RIO::URIRef,abs)
    assert_equal('file://host/a/b/c',abs.to_s)
    assert_equal(bstr,abs.base.to_s)
  end

  def test_b_not_nil_abs
    alturi = Alt::URI::File.new
    ustr = 'b/c'
    bstr = 'file://host/a/d'
    u = RIO::URIRef.build(ustr,:base => bstr)
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
    u = RIO::URIRef.build(rstr,:base => bstr)
    rel = u.rel
    assert_kind_of(RIO::URIRef,rel)
    assert_equal(rstr,rel.to_s)
    assert_equal(bstr,rel.base.to_s)
  end

  def test_b_not_nil_rel
    alturi = Alt::URI::File.new
    rstr = 'b/c'
    bstr = 'file://host/a/d'
    u = RIO::URIRef.build(rstr,:base => bstr)
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
    u = RIO::URIRef.build(astr,:base => bstr)
    rel = u.rel
    assert_equal("../c/d",rel.to_s)
    u = RIO::URIRef.build(bstr,:base => astr)
    rel = u.rel
    assert_equal("../e/f",rel.to_s)
  end





    end
    
  end
end

