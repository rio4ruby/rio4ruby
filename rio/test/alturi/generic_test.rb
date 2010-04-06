#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require "test/unit"
require 'rio/alturi'

module Alt::URI::UnitTest
  module Generic
    module Tests

      def test_initialize
        u = Alt::URI::Generic.new
        assert_equal("",u.path)
      end

      def test_create
        h = {
          :scheme => 'HTTP',
          :userinfo => 'riotest@rio4ruby.com:riotest',
          :host => 'AHost.COM',
          :port => 88,
          :path => '/loc/My Stuff',
          :query => "url=ftp://b.com/dir?q=a#b",
          :fragment => "url=ftp://b.com/dir?q=a#b",
        }
        u = Alt::URI::Generic.create(h)
        assert_equal('http://riotest%40rio4ruby.com:riotest@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b',u.uri)
        assert_equal('http',u.scheme)
        assert_equal('riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88',u.authority)
        assert_equal('riotest@rio4ruby.com:riotest',u.userinfo)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
        assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
        assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
      end
      def test_empty_create
        h = {}
        u = Alt::URI::Generic.create(h)
        assert_equal('',u.uri)
        assert_nil(u.scheme)
        assert_nil(u.authority)
        assert_nil(u.userinfo)
        assert_nil(u.port)
        assert_nil(u.host)
        assert_equal('',u.path)
        assert_nil(u.query)
        assert_nil(u.fragment)
      end
      def test_nil_create
        u = Alt::URI::Generic.create()
        assert_equal('',u.uri)
        assert_nil(u.scheme)
        assert_nil(u.authority)
        assert_nil(u.userinfo)
        assert_nil(u.port)
        assert_nil(u.host)
        assert_equal('',u.path)
        assert_nil(u.query)
        assert_nil(u.fragment)
      end
      def test_scheme
        u = Alt::URI::Generic.new
        assert_nil(u.scheme)
      end

      def test_scheme=
          u = Alt::URI::Generic.new
        u.scheme = 'HTTP'
        assert_equal('http', u.scheme)
        assert_equal('http:', u.to_s)
      end

      def test_host
        u = Alt::URI::Generic.new
        assert_nil(u.host)
      end

      def test_host=
          u = Alt::URI::Generic.new
        u.host = 'Rio4Ruby.com'
        assert_equal('rio4ruby.com', u.host)
        assert_equal('rio4ruby.com', u.authority)
        assert_equal('//rio4ruby.com', u.to_s)
      end

      def test_host2=
          u = Alt::URI::Generic.new
        u.authority = 'riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88'
        u.host = nil
        assert_nil(u.host)
        assert_nil(u.authority)
      end

      def test_port
        u = Alt::URI::Generic.new
        assert_nil(u.port)
      end

      def test_path=
          u = Alt::URI::Generic.new
        u.path = '/loc/My Stuff'
        assert_equal('/loc/My Stuff', u.path)
        assert_equal('/loc/My%20Stuff', u.to_s)

        u.path = '/loc/other_stuff'
        assert_equal('/loc/other_stuff', u.path)

      end

      def test_path2=
          u = Alt::URI::Generic.new
        u.path = nil
        assert_not_nil(u.path)
        assert('', u.path.empty?)
      end

      def test_path
        u = Alt::URI::Generic.new
        assert_not_nil(u.path)
        assert_equal("",u.path)
      end

      def test_query=
          u = Alt::URI::Generic.new
        u.query = "url=ftp://b.com/dir?q=a#b"
        assert_equal("url=ftp://b.com/dir?q=a#b", u.query)
        assert_equal("?url=ftp://b.com/dir?q=a%23b", u.to_s)
      end

      def test_query
        u = Alt::URI::Generic.new
        assert_nil(u.query)
      end

      def test_fragment=
          u = Alt::URI::Generic.new
        u.fragment = "url=ftp://b.com/dir?q=a#b"
        assert_equal("url=ftp://b.com/dir?q=a#b", u.fragment)
        assert_equal("#url=ftp://b.com/dir?q=a%23b", u.to_s)
      end

      def test_fragment
        u = Alt::URI::Generic.new
        assert_nil(u.fragment)
      end

      def test_userinfo=
          u = Alt::URI::Generic.new
        u.host = 'ahost.com'
        u.userinfo = 'riotest@rio4ruby.com:riotest'
        assert_equal('riotest@rio4ruby.com:riotest',u.userinfo)
        assert_equal('riotest%40rio4ruby.com:riotest@ahost.com',u.authority)
        assert_equal('//riotest%40rio4ruby.com:riotest@ahost.com',u.to_s)
      end

      def test_userinfo
        u = Alt::URI::Generic.new
        assert_nil(u.userinfo)
      end

      def test_port=
          u = Alt::URI::Generic.new
        u.port = 80
        assert_equal("80",u.port)
      end

      def test_authority
        u = Alt::URI::Generic.new
        assert_nil(u.authority)
        u.host = 'Rio4Ruby.com'
        assert_equal('rio4ruby.com',u.authority)
        u.port = 88
        assert_equal('rio4ruby.com:88',u.authority)
        u.userinfo = 'riotest@rio4ruby.com:riotest'
        assert_equal('riotest%40rio4ruby.com:riotest@'+'rio4ruby.com'+':88',u.authority)
        u.host = nil
        assert_nil(u.authority)
      end

      def test_authority=
          u = Alt::URI::Generic.new
        u.authority = 'riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88'
        assert_equal('riotest@rio4ruby.com:riotest',u.userinfo)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('riotest%40rio4ruby.com:riotest@ahost.com:88',u.authority)
        assert_equal('//riotest%40rio4ruby.com:riotest@ahost.com:88',u.to_s)
      end

      def test_authority2=
          u = Alt::URI::Generic.new
        u.authority = 'riotest%40rio4ruby.com:riotest'+'@'+'AHost.COM'+':'+'88'
        assert_equal('riotest@rio4ruby.com:riotest',u.userinfo)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('riotest%40rio4ruby.com:riotest@ahost.com:88',u.authority)
        assert_equal('//riotest%40rio4ruby.com:riotest@ahost.com:88',u.to_s)
      end

      def test_to_s
        u = Alt::URI::Generic.new
        u.scheme = 'http'
        u.authority = 'riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88'
        u.path = '/loc/My Stuff'
        u.query = "url=ftp://b.com/dir?q=a#b"
        u.fragment = 'frag'
        assert_equal('http://riotest%40rio4ruby.com:riotest@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.to_s)
      end

      def test_uri=
          u = Alt::URI::Generic.new
        u.uri = 'http://riotest%40rio4ruby.com:riotest@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
        assert_equal('http',u.scheme)
        assert_equal('riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88',u.authority)
        assert_equal('riotest@rio4ruby.com:riotest',u.userinfo)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
        assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
        assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
      end

      def test_uri2=
          u = Alt::URI::Generic.new
        u.uri = 'HTTP://riotest%40rio4ruby.com:riotest@AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
        assert_equal('http',u.scheme)
        assert_equal('riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88',u.authority)
        assert_equal('riotest@rio4ruby.com:riotest',u.userinfo)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
        assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
        assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
      end

      def test_subscript
        u = Alt::URI::Generic.new
        u.uri = 'HTTP://riotest%40rio4ruby.com:riotest@AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
        assert_equal(u.scheme,u[:scheme])
        assert_equal(u.authority,u[:authority])
        assert_equal(u.userinfo,u[:userinfo])
        assert_equal(u.port,u[:port])
        assert_equal(u.host,u[:host])
        assert_equal(u.path,u[:path])
        assert_equal(u.query,u[:query])
        assert_equal(u.fragment,u[:fragment])
        assert_equal(u.uri,u[:uri])
      end

      def test_subscript0
        u = Alt::URI::Generic.new
        assert_nil(u[:scheme])
        assert_nil(u[:authority])
        assert_nil(u[:userinfo])
        assert_nil(u[:port])
        assert_nil(u[:host])
        assert(u[:path].empty?)
        assert_nil(u[:query])
        assert_nil(u[:fragment])
        assert(u[:uri].empty?)
      end

      def test_to_s2
        u = Alt::URI::Generic.new
        u.scheme = 'http'
        u.userinfo = 'riotest@rio4ruby.com:riotest'
        u.host = 'AHost.COM'
        u.port = 88
        u.path = '/loc/My Stuff'
        u.query = "url=ftp://b.com/dir?q=a#b"
        u.fragment = 'frag'
        assert_equal('http://riotest%40rio4ruby.com:riotest@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.to_s)
      end

      def test_uri
        u = Alt::URI::Generic.new
        u.scheme = 'HTTP'
        u.userinfo = 'riotest@rio4ruby.com:riotest'
        u.host = 'AHost.COM'
        u.port = 88
        u.path = '/loc/My Stuff'
        u.query = "url=ftp://b.com/dir?q=a#b"
        u.fragment = 'frag'
        assert_equal('http://riotest%40rio4ruby.com:riotest@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.uri)
      end

      def test_absolute?
        u = Alt::URI::Generic.new
        assert !u.absolute?
        u.path = '/loc'
        assert !u.absolute?
        u.authority = 'ahost'
        assert !u.absolute?
        u.scheme = 'ftp'
        assert u.absolute?
      end
      def test_relative?
        u = Alt::URI::Generic.new
        assert u.relative?
        u.path = '/loc'
        assert u.relative?
        u.authority = 'ahost'
        assert u.relative?
        u.scheme = 'ftp'
        assert !u.relative?
      end
      
      def test_abs
        base = Alt::URI::Generic.parse('file:///loc/dev/rio/')
        rel = Alt::URI::Generic.parse('../uri/')
        abs = rel.abs(base)
        assert_instance_of(::Alt::URI::File,abs)
        assert_equal('file:///loc/dev/uri/', abs.to_s)
      end

      def test_abs_abs
        base = Alt::URI::Generic.parse('http://ahost.com/loc/dev/rio/')
        rel = Alt::URI::Generic.parse('file:///loc/dev/uri/')
        abs = rel.abs(base)
        assert_instance_of(::Alt::URI::File,abs)
        assert_equal('file:///loc/dev/uri/', abs.to_s)
      end
      
      def test_rel
        base = Alt::URI::Generic.parse('file:///loc/dev/rio/')
        url = Alt::URI::Generic.parse('file:///loc/dev/uri/')
        rel = url.rel(base)
        assert_instance_of(::Alt::URI::Generic,rel)
        assert_equal('../uri/', rel.to_s)
      end


    end
    
    class TestCase < Test::Unit::TestCase
      include Tests
    end

  end
end

