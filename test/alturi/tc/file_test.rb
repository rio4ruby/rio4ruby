#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require "test/unit"
require 'rio/alturi'

module Alt::URI::UnitTest
  module File
    module Tests
      def test_initialize
        u = Alt::URI::File.new
        assert_equal("",u.path)
        assert_equal("file",u.scheme)
        assert_equal("",u.authority)
      end

      def test_create
        h = {
          :scheme => 'FILE',
          :host => 'AHost.COM',
          :path => '/loc/My Stuff',
        }
        u = Alt::URI::File.create(h)
        assert_equal('file://ahost.com/loc/My%20Stuff',u.uri)
        assert_equal('file',u.scheme)
        assert_equal('ahost.com',u.authority)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
      end
      def test_empty_create
        h = {}
        u = Alt::URI::File.create(h)
        assert_equal('file://',u.uri)
        assert_equal('file',u.scheme)
        assert_equal('',u.authority)
        assert_equal('',u.host)
        assert_equal('',u.path)
      end
      
      def test_nil_create
        u = Alt::URI::File.create
        assert_equal('file://',u.uri)
        assert_equal('file',u.scheme)
        assert_equal('',u.authority)
        assert_equal('',u.host)
        assert_equal('',u.path)
      end
      
      def test_path_create
        h = {:path => "/loc/My Stuff"}
        u = Alt::URI::File.create(h)
        assert_equal('file:///loc/My%20Stuff',u.uri)
        assert_equal('file',u.scheme)
        assert_equal('',u.authority)
        assert_equal('',u.host)
        assert_equal('/loc/My Stuff',u.path)
      end
      
      def test_scheme
        u = Alt::URI::File.new
        assert_equal("file",u.scheme)
      end

      def test_scheme=
          u = Alt::URI::File.new
        u.scheme = 'file'
        assert_equal('file', u.scheme)
        assert_equal('file://', u.to_s)
      end
      def test_scheme2=
          u = Alt::URI::File.new
        u.scheme = nil
        assert_equal('file', u.scheme)
        assert_equal('file://', u.to_s)
      end
      def test_scheme3=
          u = Alt::URI::File.new
        u.scheme = ""
        # TODO: What should happen here
        #assert_equal('file', u.scheme)
        #assert_equal('file://', u.to_s)
      end
      def test_scheme4=
          u = Alt::URI::File.new
        u.scheme = "goofy"
        # TODO: What should happen here
        #assert_equal('file', u.scheme)
        #assert_equal('file://', u.to_s)
      end
      def test_scheme5=
          u = Alt::URI::File.new
        u.scheme = "html"
        # TODO: What should happen here
        #assert_equal('file', u.scheme)
        #assert_equal('file://', u.to_s)
      end
      def test_host
        u = Alt::URI::File.new
        assert_not_nil(u.host)
        assert(u.host.empty?)
      end

      def test_host=
          u = Alt::URI::File.new
        u.host = 'Rio4Ruby.com'
        assert_equal('rio4ruby.com', u.host)
        assert_equal('rio4ruby.com', u.authority)
        assert_equal('file://rio4ruby.com', u.to_s)
      end

      def test_host2=
          u = Alt::URI::File.new
        u.host = nil
        assert(u.host.empty?)
        assert(u.authority.empty?)
      end

      def test_host3=
          u = Alt::URI::File.new
        u.host = 'ahost'
        assert_equal(u.authority,u.host)
      end

      def test_path=
          u = Alt::URI::File.new
        u.path = '/loc/My Stuff'
        assert_equal('/loc/My Stuff', u.path)
        assert_equal('file:///loc/My%20Stuff', u.to_s)

        u.path = '/loc/other_stuff'
        assert_equal('/loc/other_stuff', u.path)

      end

      def test_path2=
          u = Alt::URI::File.new
        u.path = nil
        assert_not_nil(u.path)
        assert(u.path.empty?)
      end
      def test_with_drive_path=
          u = Alt::URI::File.new
        str = "C:/My Stuff"
        u.path = str
        assert_equal(str,u.path)
        assert_equal("file:///C:/My%20Stuff",u.uri)
      end
      def test_with_drive2_path=
          u = Alt::URI::File.new
        str = "C:/My Stuff"
        u.path = "/"+str
        assert_equal(str,u.path)
        assert_equal("file:///C:/My%20Stuff",u.uri)
      end
      def test_path
        u = Alt::URI::File.new
        assert_not_nil(u.path)
        assert_equal("",u.path)
      end
      def test_with_drive_path
        u = Alt::URI::File.new
        u.uri = "file:///C:/My%20Stuff"
        assert_equal('C:/My Stuff',u.path)
      end


      def test_authority
        u = Alt::URI::File.new
        assert(u.authority.empty?)
        u.host = 'Rio4Ruby.com'
        assert_equal('rio4ruby.com',u.authority)
        u.host = nil
        assert(u.authority.empty?)
      end

      def test_authority=
          u = Alt::URI::File.new
        u.authority = 'AHost.COM'
        assert_equal('ahost.com',u.host)
        assert_equal('ahost.com',u.authority)
        assert_equal('file://ahost.com',u.to_s)
      end
      def test_nil_authority=
          u = Alt::URI::File.new
        u.authority = nil
        assert_equal('',u.host)
        assert_equal('',u.authority)
        assert_equal('file://',u.to_s)
      end

      def test_to_s
        u = Alt::URI::File.new
        u.scheme = 'file'
        u.authority = 'ahost.com'
        u.path = '/loc/My Stuff'
        assert_equal('file://ahost.com/loc/My%20Stuff',u.to_s)
      end

      def test_uri=
          u = Alt::URI::File.new
        u.uri = 'file://ahost.com/loc/My%20Stuff'
        assert_equal('file',u.scheme)
        assert_equal('ahost.com',u.authority)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
      end

      def test_2_uri=
          u = Alt::URI::File.new
        u.uri = 'file://AHost.COM/loc/My%20Stuff'
        assert_equal('file',u.scheme)
        assert_equal('ahost.com',u.authority)
        assert_equal('ahost.com',u.host)
        assert_equal('/loc/My Stuff',u.path)
      end

      def test_nil_uri=
          u = Alt::URI::File.new
        u.scheme = 'file'
        u.host = 'AHost.COM'
        u.path = '/loc/My Stuff'
        assert_equal('file://ahost.com/loc/My%20Stuff',u.uri)
        u.uri = nil
        assert_equal('file://',u.to_s)
      end

      def test_subscript
        u = Alt::URI::File.new
        u.uri = 'file://riotest%40rio4ruby.com:riotest@AHost.COM:88/loc/My%20Stuff?url=ftp://b.com/dir?q=a%23b#url=ftp://b.com/dir?q=a%23b'
        assert_equal(u.parts[:scheme],u[:scheme])
        assert_equal(u.parts[:authority],u[:authority])
        assert_equal(u.authority,u[:authority].to_s)
        assert_equal(u.parts[:host],u[:host])
        assert_equal(u.parts[:path],u[:path])
      end

      def test_subscript0
        u = Alt::URI::File.new
        assert_equal("file",u[:scheme])
        assert(u[:authority].to_s.empty?)
        assert(u[:authority][:host].empty?)
        assert(u[:path].empty?)
      end

      def test_to_s2
        u = Alt::URI::File.new
        u.scheme = 'file'
        u.host = 'AHost.COM'
        u.path = '/loc/My Stuff'
        assert_equal('file://ahost.com/loc/My%20Stuff',u.to_s)
      end

      def test_uri
        u = Alt::URI::File.new
        u.scheme = 'file'
        u.host = 'AHost.COM'
        u.path = '/loc/My Stuff'
        assert_equal('file://ahost.com/loc/My%20Stuff',u.uri)
      end

      def test_absolute?
        u = Alt::URI::File.new
        assert u.absolute?
        u.path = '/loc'
        assert u.absolute?
        u.authority = 'ahost'
        assert u.absolute?
      end
      def test_relative?
        u = Alt::URI::File.new
        assert !u.relative?
        u.path = '/loc'
        assert !u.relative?
        u.authority = 'ahost'
        assert !u.relative?
      end
      
      def test_abs
        base = Alt::URI::File.parse('/loc/dev/rio/')
        rel = Alt::URI::Generic.parse('../uri/')
        abs = rel.abs(base)
        assert_instance_of(::Alt::URI::File,abs)
        assert_equal('file:///loc/dev/uri/', abs.to_s)
      end

      def test_diff_scheme_abs
        base = Alt::URI::Generic.parse('http://ahost.com/loc/dev/rio/')
        rel = Alt::URI::File.parse('/loc/dev/uri/')
        abs = rel.abs(base)
        assert_instance_of(::Alt::URI::File,abs)
        assert_equal('file:///loc/dev/uri/', abs.to_s)
      end
      
      def test_diff_host_abs
        base = Alt::URI::Generic.parse('file://ahost/loc/dev/rio/')
        rel = Alt::URI::File.parse('file:///loc/dev/uri/')
        abs = rel.abs(base)
        assert_instance_of(::Alt::URI::File,abs)
        assert_equal('file:///loc/dev/uri/', abs.to_s)
      end
      
      def test_keep_host_abs
        base = Alt::URI::File.parse('file://ahost/loc/dev/rio/')
        rel = Alt::URI::Generic.parse('../uri/')
        abs = rel.abs(base)
        assert_instance_of(::Alt::URI::File,abs)
        assert_equal('file://ahost/loc/dev/uri/', abs.to_s)
      end
      
      def test_rel
        base = Alt::URI::File.parse('/loc/dev/rio/')
        url = Alt::URI::File.parse('/loc/dev/uri/')
        rel = url.rel(base)
        assert_instance_of(::Alt::URI::Generic,rel)
        assert_equal('../uri/', rel.to_s)
      end
      def test_diff_host_rel
        base = Alt::URI::File.parse('file://ahost/loc/dev/rio/')
        url = Alt::URI::File.parse('/loc/dev/uri/')
        rel = url.rel(base)
        assert_instance_of(::Alt::URI::File,rel)
        assert_equal('file:///loc/dev/uri/', rel.to_s)
        rel = base.rel(url)
        assert_instance_of(::Alt::URI::File,rel)
        assert_equal('file://ahost/loc/dev/rio/', rel.to_s)
      end


    end

  end
end

