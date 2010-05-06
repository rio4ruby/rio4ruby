#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require "test/unit"
require 'rio/alturi/uri_parts'

module Alt::URI::UnitTest
  module URIParts
    module Tests


      def test_initialize
        u = Alt::URI::Gen::URIParts.new
        assert_equal("",u.path)
      end

      def test_create
        h = {
          :scheme => 'HTTP',
          :userinfo => 'riotest%40rio4ruby.com:riotest',
          :host => 'AHost.COM',
          :port => 88,
          :path => '/loc/My Stuff',
          :query => "url=ftp://b.com/dir?q=a#b",
          :fragment => "url=ftp://b.com/dir?q=a#b",
        }
        u = Alt::URI::Gen::URIParts.create(h)
        assert_equal('http://riotest%40rio4ruby.com@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b',u.uri)
        assert_equal('http',u.scheme)
        assert_equal('riotest%40rio4ruby.com'+'@'+'ahost.com'+':'+'88',u.authority)
        assert_equal('riotest%40rio4ruby.com',u.userinfo)
        assert_equal('riotest@rio4ruby.com',u.user)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
        assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
        assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
      end

      def test_create2
        h = {
          :scheme => 'HTTP',
          :user => 'riotest@rio4ruby.com',
          :password => 'riotest',
          :host => 'AHost.COM',
          :port => 88,
          :path => '/loc/My Stuff',
          :query => "url=ftp://b.com/dir?q=a#b",
          :fragment => "url=ftp://b.com/dir?q=a#b",
        }
        u = Alt::URI::Gen::URIParts.create(h)
        assert_equal('http://riotest%40rio4ruby.com@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b',u.uri)
        assert_equal('http',u.scheme)
        assert_equal('riotest%40rio4ruby.com'+'@'+'ahost.com'+':'+'88',u.authority)
        assert_equal('riotest%40rio4ruby.com',u.userinfo)
        assert_equal('riotest@rio4ruby.com',u.user)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
        assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
        assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
      end

      def test_scheme
        u = Alt::URI::Gen::URIParts.new
        assert_nil(u.scheme)
      end

      def test_scheme_assign
        u = Alt::URI::Gen::URIParts.new
        u.scheme = 'HTTP'
        assert_equal('http', u.scheme)
        assert_equal('http:', u.to_s)
      end

      def test_host
        u = Alt::URI::Gen::URIParts.new
        assert_nil(u.host)
      end

      def test_host_assign
        u = Alt::URI::Gen::URIParts.new
        u.host = 'Rio4Ruby.com'
        assert_equal('rio4ruby.com', u.host)
        assert_equal('rio4ruby.com', u.authority)
        assert_equal('//rio4ruby.com', u.to_s)
      end

      def test_host2_assign
        u = Alt::URI::Gen::URIParts.new
        u.authority = 'riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88'
        u.host = nil
        assert_nil(u.host)
        assert_nil(u.authority)
      end

      def test_port
        u = Alt::URI::Gen::URIParts.new
        assert_nil(u.port)
      end

      def test_path_assign
        u = Alt::URI::Gen::URIParts.new
        u.path = '/loc/My Stuff'
        assert_equal('/loc/My Stuff', u.path)
        assert_equal('/loc/My%20Stuff', u.to_s)

        u.path = '/loc/other_stuff'
        assert_equal('/loc/other_stuff', u.path)

      end

      def test_path2_assign
        u = Alt::URI::Gen::URIParts.new
        u.path = nil
        assert_not_nil(u.path)
        assert(u.path.empty?)
      end

      def test_path
        u = Alt::URI::Gen::URIParts.new
        assert_not_nil(u.path)
        assert_equal("",u.path)
      end

      def test_query_assign
        u = Alt::URI::Gen::URIParts.new
        u.query = "url=ftp://b.com/dir?q=a#b"
        assert_equal("url=ftp://b.com/dir?q=a#b", u.query)
        assert_equal("?url=ftp://b.com/dir?q=a%23b", u.to_s)
      end

      def test_query
        u = Alt::URI::Gen::URIParts.new
        assert_nil(u.query)
      end

      def test_empty_query
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c?")
        assert_equal("",u.query)
      end

      def test_empty_part_query
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c?&")
        assert_equal(["",""],u.query)
      end

      def test_array_query
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c?d&e&f")
        assert_instance_of(::Array,u.query)
        assert_equal(3,u.query.size)
        assert_equal(['d','e','f'],u.query)
      end

      def test_array2_query
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c?d&e%20k&f")
        assert_instance_of(::Array,u.query)
        assert_equal(3,u.query.size)
        assert_equal(['d','e k','f'],u.query)
      end

      def test_array_query_assign
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c")
        ans = (u.query = ['d','e','f'])
        assert_equal("http://a.com/b/c?d&e&f",u.to_s)
        assert_instance_of(::Array,u.query)
        assert_equal(['d','e','f'],u.query)
      end
      def test_array2_query_assign
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c")
        ans = (u.query = ['d','e k','f'])
        assert_equal("http://a.com/b/c?d&e%20k&f",u.to_s)
      end

      def test_array_url_in_query_assign
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c")
        q1 = "http://a/b?c&d"
        q2 = "http://a/b?e&f"
        ans = (u.query = ['q1='+q1,'q2='+q2])
        assert_equal("http://a.com/b/c?q1=http://a/b?c%26d&q2=http://a/b?e%26f",u.to_s)
      end

      def test_array_url_in_query
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c?q1=http://a/b?c%26d&q2=http://a/b?e%26f")
        #u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c")
        assert_equal(["q1=http://a/b?c&d","q2=http://a/b?e&f"], u.query)
      end

      def test_array_url_frag_in_query
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c?q1=http://a/b?c%26d%23x&q2=http://a/b?e%26f%23y#z")
        #u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c")
        assert_equal(["q1=http://a/b?c&d#x","q2=http://a/b?e&f#y"], u.query)
        assert_equal("z", u.fragment)
      end

      def test_array_url_frag_in_query_assign
        u = Alt::URI::Gen::URIParts.parse("http://a.com/b/c#z")
        q1 = "http://a/b?c&d#x"
        q2 = "http://a/b?e&f#y"
        ans = (u.query = ['q1='+q1,'q2='+q2])
        assert_equal("http://a.com/b/c?q1=http://a/b?c%26d%23x&q2=http://a/b?e%26f%23y#z",u.to_s)
      end






      def test_fragment_assign
        u = Alt::URI::Gen::URIParts.new
        u.fragment = "url=ftp://b.com/dir?q=a#b"
        assert_equal("url=ftp://b.com/dir?q=a#b", u.fragment)
        assert_equal("#url=ftp://b.com/dir?q=a%23b", u.to_s)
      end

      def test_fragment
        u = Alt::URI::Gen::URIParts.new
        assert_nil(u.fragment)
      end

      def test_userinfo_assign
        u = Alt::URI::Gen::URIParts.new
        u.host = 'ahost.com'
        u.userinfo = 'riotest%40rio4ruby.com:riotest'
        assert_equal('riotest%40rio4ruby.com',u.userinfo)
        assert_equal('riotest@rio4ruby.com',u.user)
        assert_equal('riotest%40rio4ruby.com@ahost.com',u.authority)
        assert_equal('//riotest%40rio4ruby.com@ahost.com',u.to_s)
      end

      def test_userinfo
        u = Alt::URI::Gen::URIParts.new
        assert_nil(u.userinfo)
      end

      def test_port_assign
        u = Alt::URI::Gen::URIParts.new
        u.port = 80
        assert_equal("80",u.port)
      end

      def test_authority
        u = Alt::URI::Gen::URIParts.new
        assert_nil(u.authority)
        u.host = 'Rio4Ruby.com'
        assert_equal('rio4ruby.com',u.authority)
        u.port = 88
        assert_equal('rio4ruby.com:88',u.authority)
        u.userinfo = 'riotest%40rio4ruby.com:riotest'
        assert_equal('riotest%40rio4ruby.com@'+'rio4ruby.com'+':88',u.authority)
        u.host = nil
        assert_nil(u.authority)
      end

      def test_authority_assign
        u = Alt::URI::Gen::URIParts.new
        u.authority = 'riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88'
        assert_equal('riotest%40rio4ruby.com',u.userinfo)
        assert_equal('riotest@rio4ruby.com',u.user)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('riotest%40rio4ruby.com@ahost.com:88',u.authority)
        assert_equal('//riotest%40rio4ruby.com@ahost.com:88',u.to_s)
      end

      def test_authority2_assign
        u = Alt::URI::Gen::URIParts.new
        u.authority = 'riotest%40rio4ruby.com:riotest'+'@'+'AHost.COM'+':'+'88'
        assert_equal('riotest%40rio4ruby.com',u.userinfo)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('riotest%40rio4ruby.com@ahost.com:88',u.authority)
        assert_equal('//riotest%40rio4ruby.com@ahost.com:88',u.to_s)
      end

      def test_to_s
        u = Alt::URI::Gen::URIParts.new
        u.scheme = 'http'
        u.authority = 'riotest%40rio4ruby.com:riotest'+'@'+'ahost.com'+':'+'88'
        u.path = '/loc/My Stuff'
        u.query = "url=ftp://b.com/dir?q=a#b"
        u.fragment = 'frag'
        assert_equal('http://riotest%40rio4ruby.com@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.to_s)
      end

      def test_uri_assign
        u = Alt::URI::Gen::URIParts.new
        u.uri = 'http://riotest%40rio4ruby.com:riotest@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
        assert_equal('http',u.scheme)
        assert_equal('riotest%40rio4ruby.com'+'@'+'ahost.com'+':'+'88',u.authority)
        assert_equal('riotest%40rio4ruby.com',u.userinfo)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
        assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
        assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
      end

      def test_2_uri_assign
        u = Alt::URI::Gen::URIParts.new
        u.uri = 'HTTP://riotest%40rio4ruby.com:riotest@AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
        assert_equal('http',u.scheme)
        assert_equal('riotest%40rio4ruby.com'+'@'+'ahost.com'+':'+'88',u.authority)
        assert_equal('riotest%40rio4ruby.com',u.userinfo)
        assert_equal('88',u.port)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
        assert_equal("url=ftp://b.com/dir?q=a#b",u.query)
        assert_equal('url=ftp://b.com/dir?q=a#b',u.fragment)
      end

      def test_nil_uri_assign
        u = Alt::URI::Gen::URIParts.new
        u.scheme = 'http'
        u.userinfo = 'riotest%40rio4ruby.com:riotest'
        u.host = 'AHost.COM'
        u.port = 88
        u.path = '/loc/My Stuff'
        u.query = "url=ftp://b.com/dir?q=a#b"
        u.fragment = 'frag'
        assert_equal('http://riotest%40rio4ruby.com@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.to_s)
        u.uri = nil
        assert_equal("",u.to_s)
      end

      def test_subscript
        u = Alt::URI::Gen::URIParts.new
        u.uri = 'HTTP://riotest%40rio4ruby.com:riotest@AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
        assert_equal(u.store[:scheme],u[:scheme])
        assert_equal(u.store[:authority],u[:authority])
        assert_equal(u.store[:userinfo],u[:userinfo])
        assert_equal(u.store[:port],u[:port])
        assert_equal(u.store[:host],u[:host])
        assert_equal(u.store[:path],u[:path])
        assert_equal(u.store[:query],u[:query])
        assert_equal(u.store[:fragment],u[:fragment])
      end

      def test_subscript_kind_of
        u = Alt::URI::Gen::URIParts.new
        u.uri = 'HTTP://riotest%40rio4ruby.com:riotest@AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
        assert_kind_of(::String,u[:scheme])
        assert_kind_of(::String,u[:path])
        assert_kind_of(::String,u[:query])
        assert_kind_of(::String,u[:fragment])

        assert_kind_of(Alt::URI::Gen::AuthParts,u[:authority])
        assert_kind_of(::String,u[:authority][:port])
        assert_kind_of(::String,u[:authority][:host])

        assert_kind_of(Alt::URI::Gen::UserInfoParts,u[:authority][:userinfo])


      end

      def xtest_subscript1
        u = Alt::URI::Gen::URIParts.new
        u.uri = 'HTTP://riotest%40rio4ruby.com:riotest@AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'

        p "#{:scheme}: #{u[:scheme].inspect}"
        p "#{:authority}: #{u[:authority].inspect}"
        p "#{:path}: #{u[:path].inspect}"
        p "#{:query}: #{u[:query].inspect}"
        p "#{:fragment}: #{u[:fragment].inspect}"

        p "[:authority][:port]: #{u[:authority][:port].inspect}"
        p "[:authority][:host]: #{u[:authority][:host].inspect}"
        p "[:authority][:userinfo]: #{u[:authority][:userinfo].inspect}"

        p "[:authority][:userinfo][:user]: #{u[:authority][:userinfo][:user].inspect}"
        p "[:authority][:userinfo][:password]: #{u[:authority][:userinfo][:password].inspect}"

      end

      def test_subscript0
        u = Alt::URI::Gen::URIParts.new
        assert_nil(u[:scheme])
        assert_nil(u[:authority])
        assert_nil(u[:userinfo])
        assert_nil(u[:port])
        assert_nil(u[:host])
        assert(u[:path].empty?)
        assert_nil(u[:query])
        assert_nil(u[:fragment])
      end

      def test_to_s2
        u = Alt::URI::Gen::URIParts.new
        u.scheme = 'http'
        u.userinfo = 'riotest%40rio4ruby.com:riotest'
        u.host = 'AHost.COM'
        u.port = 88
        u.path = '/loc/My Stuff'
        u.query = "url=ftp://b.com/dir?q=a#b"
        u.fragment = 'frag'
        assert_equal('http://riotest%40rio4ruby.com@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.to_s)
      end

      def test_uri
        u = Alt::URI::Gen::URIParts.new
        u.scheme = 'HTTP'
        u.userinfo = 'riotest%40rio4ruby.com:riotest'
        u.host = 'AHost.COM'
        u.port = 88
        u.path = '/loc/My Stuff'
        u.query = "url=ftp://b.com/dir?q=a#b"
        u.fragment = 'frag'
        assert_equal('http://riotest%40rio4ruby.com@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.uri)
      end

      def test_uri2
        u = Alt::URI::Gen::URIParts.new
        u.scheme = 'HTTP'
        u.user = 'riotest@rio4ruby.com'
        u.password = 'riotest'
        u.host = 'AHost.COM'
        u.port = 88
        u.path = '/loc/My Stuff'
        u.query = "url=ftp://b.com/dir?q=a#b"
        u.fragment = 'frag'
        assert_equal('http://riotest%40rio4ruby.com@ahost.com:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#frag',u.uri)
      end

      def test_absolute?
        u = Alt::URI::Gen::URIParts.new
        assert !u.absolute?
        u.path = '/loc'
        assert !u.absolute?
        u.authority = 'ahost'
        assert !u.absolute?
        u.scheme = 'ftp'
        assert u.absolute?
      end
      def test_relative?
        u = Alt::URI::Gen::URIParts.new
        assert u.relative?
        u.path = '/loc'
        assert u.relative?
        u.authority = 'ahost'
        assert u.relative?
        u.scheme = 'ftp'
        assert !u.relative?
      end
      
      def test_abs
        base = Alt::URI::Gen::URIParts.parse('file:///loc/dev/rio/')
        rel = Alt::URI::Gen::URIParts.parse('../uri/')
        abs = rel.abs(base)
        assert(abs.absolute?)
        assert_equal('file:///loc/dev/uri/', abs.to_s)
      end

      
      def test_rel
        base = Alt::URI::Gen::URIParts.parse('file:///loc/dev/rio/')
        url = Alt::URI::Gen::URIParts.parse('file:///loc/dev/uri/')
        rel = url.rel(base)
        assert(rel.relative?)
        assert_equal('../uri/', rel.to_s)
      end



    end
    
    class TestCase < Test::Unit::TestCase
      include Tests
    end

  end
end



