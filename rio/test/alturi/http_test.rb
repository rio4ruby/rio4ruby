#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require "test/unit"
require 'rio/alturi'

module Alt::URI::UnitTest
  module HTTP
    module Tests
  def test_initialize
    u = Alt::URI::HTTP.new
    assert_equal("",u.path)
    assert_equal("http",u.scheme)
    assert_equal("",u.authority)
    assert_equal("",u.host)
  end

  def test_create
    h = {
      :scheme => 'HTTP',
      :host => 'AHost.COM',
      :port => 88,
      :path => '/loc/My Stuff',
      :query => "url=ftp://b.com/dir?q=a#b",
      :fragment => "url=ftp://b.com/dir?q=a#b",
    }
    u = Alt::URI::HTTP.create(h)
    assert_equal('http://ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b',u.uri)
    assert_equal('http',u.scheme)
    assert_equal('ahost.com'+':'+'88',u.authority)
    assert_equal('88',u.port)
    assert_equal('ahost.com',u.host)
    assert_equal('/loc/My Stuff',u.path)
    assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
    assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
  end
  def test_empty_create
    h = {}
    u = Alt::URI::HTTP.create(h)
    assert_equal('http://',u.uri)
    assert_equal('http',u.scheme)
    assert_equal('',u.authority)
    assert_nil(u.port)
    assert_equal('',u.host)
    assert_equal('',u.path)
    assert_nil(u.query)
    assert_nil(u.fragment)
  end
  def test_nil_create
    u = Alt::URI::HTTP.create()
    assert_equal('http://',u.uri)
    assert_equal('http',u.scheme)
    assert_equal('',u.authority)
    assert_nil(u.port)
    assert_equal('',u.host)
    assert_equal('',u.path)
    assert_nil(u.query)
    assert_nil(u.fragment)
  end
  def test_scheme
    u = Alt::URI::HTTP.new
    assert_equal("http",u.scheme)
  end

  def test_scheme=
    u = Alt::URI::HTTP.new
    u.scheme = 'HTTP'
    assert_equal('http', u.scheme)
    assert_equal('http://', u.to_s)
  end

  def test_host
    u = Alt::URI::HTTP.new
    assert_equal("",u.host)
  end

  def test_host=
    u = Alt::URI::HTTP.new
    u.host = 'Rio4Ruby.com'
    assert_equal('rio4ruby.com', u.host)
    assert_equal('rio4ruby.com', u.authority)
    assert_equal('http://rio4ruby.com', u.to_s)
  end

  def test_host2=
    u = Alt::URI::HTTP.new
    u.authority = 'ahost.com'+':'+'88'
    u.host = nil
    assert(u.host.empty?)
    assert_equal(":88",u.authority)
  end

  def test_port
    u = Alt::URI::HTTP.new
    assert_nil(u.port)
  end

  def test_path=
    u = Alt::URI::HTTP.new
    u.path = '/loc/My Stuff'
    assert_equal('/loc/My Stuff', u.path)
    assert_equal('http:///loc/My%20Stuff', u.to_s)

    u.path = '/loc/other_stuff'
    assert_equal('/loc/other_stuff', u.path)

  end

  def test_path2=
    u = Alt::URI::HTTP.new
    u.path = nil
    assert_not_nil(u.path)
    assert('', u.path.empty?)
  end

  def test_path
    u = Alt::URI::HTTP.new
    assert_not_nil(u.path)
    assert_equal("",u.path)
  end

  def test_query=
    u = Alt::URI::HTTP.new
    u.query = "url=ftp://b.com/dir?q=a#b"
    assert_equal("url=ftp://b.com/dir?q=a#b", u.query)
    assert_equal("http://?url=ftp://b.com/dir?q=a%23b", u.to_s)
  end

  def test_query
    u = Alt::URI::HTTP.new
    assert_nil(u.query)
  end

  def test_fragment=
    u = Alt::URI::HTTP.new
    u.fragment = "url=ftp://b.com/dir?q=a#b"
    assert_equal("url=ftp://b.com/dir?q=a#b", u.fragment)
    assert_equal("http://#url=ftp://b.com/dir?q=a%23b", u.to_s)
  end

  def test_fragment
    u = Alt::URI::HTTP.new
    assert_nil(u.fragment)
  end

  def test_port=
    u = Alt::URI::HTTP.new
    u.port = 80
    assert_equal("80",u.port)
  end

  def test_authority
    u = Alt::URI::HTTP.new
    assert_equal("",u.authority)
    u.host = 'Rio4Ruby.com'
    assert_equal('rio4ruby.com',u.authority)
    u.port = 88
    assert_equal('rio4ruby.com:88',u.authority)
    assert_equal('rio4ruby.com'+':88',u.authority)
  end

  def test_authority=
    u = Alt::URI::HTTP.new
    u.authority = 'ahost.com'+':'+'88'
    assert_equal('88',u.port)
    assert_equal('ahost.com',u.host)
    assert_equal('ahost.com:88',u.authority)
    assert_equal('http://ahost.com:88',u.to_s)
  end

  def test_authority2=
    u = Alt::URI::HTTP.new
    u.authority = 'AHost.COM'+':'+'88'
    assert_equal('88',u.port)
    assert_equal('ahost.com',u.host)
    assert_equal('ahost.com:88',u.authority)
    assert_equal('http://ahost.com:88',u.to_s)
  end

  def test_to_s
    u = Alt::URI::HTTP.new
    u.scheme = 'http'
    u.authority = 'ahost.com'+':'+'88'
    u.path = '/loc/My Stuff'
    u.query = "url=ftp://b.com/dir?q=a#b"
    u.fragment = 'frag'
    assert_equal('http://ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.to_s)
  end

  def test_uri=
    u = Alt::URI::HTTP.new
    u.uri = 'http://ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
    assert_equal('http',u.scheme)
    assert_equal('ahost.com'+':'+'88',u.authority)
    assert_equal('88',u.port)
    assert_equal('ahost.com',u.host)
    assert_equal('/loc/My Stuff',u.path)
    assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
    assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
  end

  def test_uri2=
    u = Alt::URI::HTTP.new
    u.uri = 'HTTP://AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
    assert_equal('http',u.scheme)
    assert_equal('ahost.com'+':'+'88',u.authority)
    assert_equal('88',u.port)
    assert_equal('ahost.com',u.host)
    assert_equal('/loc/My Stuff',u.path)
    assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
    assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
  end

  def test_subscript
    u = Alt::URI::HTTP.new
    u.uri = 'HTTP://AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
    assert_equal(u.parts[:scheme],u[:scheme])
    assert_equal(u.parts[:authority],u[:authority])
    assert_equal(u.parts[:path],u[:path])
    assert_equal(u.parts[:query],u[:query])
    assert_equal(u.parts[:fragment],u[:fragment])
  end

  def test_subscript0
    u = Alt::URI::HTTP.new
    assert_equal('http',u[:scheme])
    assert_equal('',u[:authority].to_s)
    assert(u[:path].empty?)
    assert_nil(u[:query])
    assert_nil(u[:fragment])
  end

  def test_to_s2
    u = Alt::URI::HTTP.new
    u.scheme = 'http'
    u.host = 'AHost.COM'
    u.port = 88
    u.path = '/loc/My Stuff'
    u.query = "url=ftp://b.com/dir?q=a#b"
    u.fragment = 'frag'
    assert_equal('http://ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.to_s)
  end

  def test_uri
    u = Alt::URI::HTTP.new
    u.scheme = 'HTTP'
    u.host = 'AHost.COM'
    u.port = 88
    u.path = '/loc/My Stuff'
    u.query = "url=ftp://b.com/dir?q=a#b"
    u.fragment = 'frag'
    assert_equal('http://ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.uri)
  end

  def test_absolute?
    u = Alt::URI::HTTP.new
    assert u.absolute?
    u.path = '/loc'
    assert u.absolute?
    u.authority = 'ahost'
    assert u.absolute?
  end
  def test_relative?
    u = Alt::URI::HTTP.new
    assert !u.relative?
    u.path = '/loc'
    assert !u.relative?
    u.authority = 'ahost'
    assert !u.relative?
  end
  
  def test_abs
    base = Alt::URI::HTTP.parse('http://ahost.com/loc/dev/rio/')
    rel = Alt::URI::Generic.parse('../uri/')
    abs = rel.abs(base)
    assert_instance_of(::Alt::URI::HTTP,abs)
    assert_equal('http://ahost.com/loc/dev/uri/', abs.to_s)
  end

  def test_abs_abs
    base = Alt::URI::HTTP.parse('http://ahost.com/loc/dev/rio/')
    rel = Alt::URI::HTTP.parse('http:///loc/dev/uri/')
    abs = rel.abs(base)
    assert_instance_of(::Alt::URI::HTTP,abs)
    assert_equal('http:///loc/dev/uri/', abs.to_s)
  end
  
  def test_rel
    base = Alt::URI::HTTP.parse('http:///loc/dev/rio/')
    url = Alt::URI::HTTP.parse('http:///loc/dev/uri/')
    rel = url.rel(base)
    assert_instance_of(::Alt::URI::Generic,rel)
    assert_equal('../uri/', rel.to_s)
  end



  def test_diff_scheme_abs
    base = Alt::URI::HTTP.parse('http://ahost.com/loc/dev/rio/')
    rel = Alt::URI::File.parse('/loc/dev/uri/')
    abs = rel.abs(base)
    assert_instance_of(::Alt::URI::File,abs)
    assert_equal('file:///loc/dev/uri/', abs.to_s)
  end
  
  def test_diff_host_abs
    base = Alt::URI::HTTP.parse('http://ahost/loc/dev/rio/')
    rel = Alt::URI::HTTP.parse('http://bhost/loc/dev/uri/')
    abs = rel.abs(base)
    assert_instance_of(::Alt::URI::HTTP,abs)
    assert_equal('http://bhost/loc/dev/uri/', abs.to_s)
  end
  
  def test_keep_host_abs
    base = Alt::URI::HTTP.parse('http://ahost/loc/dev/rio/')
    rel = Alt::URI::Generic.parse('../uri/')
    abs = rel.abs(base)
    assert_instance_of(::Alt::URI::HTTP,abs)
    assert_equal('http://ahost/loc/dev/uri/', abs.to_s)
  end
  
  def test_diff_host_rel
    base = Alt::URI::HTTP.parse('http://ahost/loc/dev/rio/')
    url = Alt::URI::HTTP.parse('http://bhost/loc/dev/uri/')
    rel = url.rel(base)
    assert_instance_of(::Alt::URI::HTTP,rel)
    assert_equal('http://bhost/loc/dev/uri/', rel.to_s)
    rel = base.rel(url)
    assert_instance_of(::Alt::URI::HTTP,rel)
    assert_equal('http://ahost/loc/dev/rio/', rel.to_s)
  end
  def test_diff_scheme_rel
    base = Alt::URI::HTTP.parse('http://ahost/loc/dev/rio/')
    url = Alt::URI::HTTP.parse('file://bhost/loc/dev/uri/')
    rel = url.rel(base)
    assert_instance_of(::Alt::URI::File,rel)
    assert_equal('file://bhost/loc/dev/uri/', rel.to_s)
    rel = base.rel(url)
    assert_instance_of(::Alt::URI::HTTP,rel)
    assert_equal('http://ahost/loc/dev/rio/', rel.to_s)
  end
  def test_diff_port_rel
    base = Alt::URI::HTTP.parse('http://ahost:80/loc/dev/rio/')
    url = Alt::URI::HTTP.parse('http://ahost:88/loc/dev/uri/')
    rel = url.rel(base)
    assert_instance_of(::Alt::URI::HTTP,rel)
    assert_equal('http://ahost:88/loc/dev/uri/', rel.to_s)
    rel = base.rel(url)
    assert_instance_of(::Alt::URI::HTTP,rel)
    assert_equal('http://ahost:80/loc/dev/rio/', rel.to_s)
  end

    end
    
    class TestCase < Test::Unit::TestCase
      include Tests
    end

  end
end

