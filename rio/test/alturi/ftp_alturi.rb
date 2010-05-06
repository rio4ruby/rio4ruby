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

      def test_new
        # $trace_states = true
        pth = 'a/b.exe'
        tc = 'i'
        upth = "/#{pth};type=#{tc}"
        ustr = "ftp://h#{upth}"
        u = ::Alt::URI.parse(ustr)
        assert_kind_of(Alt::URI::FTP,u)
        assert_equal(ustr, u.to_s)
        assert_equal(pth, u.path)
        assert_equal(tc,u.typecode)
        assert_equal(upth,u[:path])
      end

      def test_assign_path
        # $trace_states = true
        pth = 'c/d.exe'
        tc = 'i'
        upth = "/#{pth};type=#{tc}"
        astr = "ftp://h#{upth}"
        ustr = "ftp://h/a/b.exe;type=#{tc}"
        u = ::Alt::URI.parse(ustr)
        u.path = pth
        assert_kind_of(Alt::URI::FTP,u)
        assert_equal(astr, u.to_s)
        assert_equal(pth, u.path)
        assert_equal(tc,u.typecode)
        assert_equal(upth,u[:path])
      end

      def test_assign_space_path
        # $trace_states = true
        pth = 'c/My Docs'
        epth = pth.sub(' ','%20')
        tc = 'i'
        upth = "/#{epth};type=#{tc}"
        astr = "ftp://h#{upth}"
        ustr = "ftp://h/a/b.exe;type=#{tc}"
        u = ::Alt::URI.parse(ustr)
        u.path = pth
        assert_kind_of(Alt::URI::FTP,u)
        assert_equal(astr, u.to_s)
        assert_equal(pth, u.path)
        assert_equal(tc,u.typecode)
        assert_equal(upth,u[:path])
      end

      def test_assign_space_root_path
        # $trace_states = true
        pth = '/c/My Docs'
        epth = pth.sub(' ','%20').sub(%r{^/},'%2F')
        tc = 'i'
        upth = "/#{epth};type=#{tc}"
        astr = "ftp://h#{upth}"
        ustr = "ftp://h/a/b.exe;type=#{tc}"
        u = ::Alt::URI.parse(ustr)
        u.path = pth
        assert_kind_of(Alt::URI::FTP,u)
        assert_equal(astr, u.to_s)
        assert_equal(pth, u.path)
        assert_equal(tc,u.typecode)
        assert_equal(upth,u[:path])
      end

      def test_assign_root_path
        # $trace_states = true
        pth = '/c/d'
        epth = pth.sub(%r{^/},'%2F')
        tc = 'i'
        upth = "/#{epth};type=#{tc}"
        astr = "ftp://h#{upth}"
        ustr = "ftp://h/a/b.exe;type=#{tc}"
        u = ::Alt::URI.parse(ustr)
        u.path = pth
        assert_kind_of(Alt::URI::FTP,u)
        assert_equal(astr, u.to_s)
        assert_equal(pth, u.path)
        assert_equal(tc,u.typecode)
        assert_equal(upth,u[:path])
      end

      def test_root_path
        # $trace_states = true
        pth = '/a/b.exe'
        tc = 'i'
        upth = "/#{pth};type=#{tc}"
        ustr = "ftp://h#{upth}"
        u = ::Alt::URI.parse(ustr)
        assert_kind_of(Alt::URI::FTP,u)
        assert_equal(ustr, u.to_s)
        assert_equal(pth, u.path)
        assert_equal(tc,u.typecode)
        assert_equal(upth,u[:path])
      end

      def test_assign_typecode
        # $trace_states = true
        ustr = "ftp://h/a/b.exe;type=i"
        u = ::Alt::URI.parse(ustr)
        assert_equal(?i,u.typecode)
        assert_equal(ustr,u.to_s)
        u.typecode = ?a
        assert_equal(?a,u.typecode)
        assert_equal(ustr.sub(/i$/,?a),u.to_s)
      end

      def test_assign_typecode_illegal
        # $trace_states = true
        ustr = "ftp://h/a/b.exe;type=i"
        u = ::Alt::URI.parse(ustr)
        assert_equal(?i,u.typecode)
        assert_equal(ustr,u.to_s)
        assert_raise ArgumentError do
          u.typecode = ?b
        end
      end

      def test_assign_typecode_symbol
        # $trace_states = true
        ustr = "ftp://h/a/b.exe;type=i"
        u = ::Alt::URI.parse(ustr)
        assert_equal(?i,u.typecode)
        assert_equal(ustr,u.to_s)
        u.typecode = :a
        assert_equal(?a,u.typecode)
        assert_equal(ustr.sub(/i$/,?a),u.to_s)
      end



    end
    
    class TestCase < Test::Unit::TestCase
      include Tests
    end

  end
end

