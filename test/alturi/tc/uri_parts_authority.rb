#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require "test/unit"
require 'rio/alturi/uri_parts'

module Alt::URI::UnitTest
  module URIPartsAuthority
    module Tests


      def test_new
        # $trace_states = true
        ui = Alt::URI::Gen::AuthParts.new
        assert(ui.store.empty?)
        assert_nil(ui.value)
        assert_equal("",ui.to_s)
      end

      def test_parse_nil
        # $trace_states = true
        ui = Alt::URI::Gen::AuthParts.parse(nil)
        assert(ui.store.empty?)
        assert_nil(ui.value)
        assert_equal("",ui.to_s)
      end

      def test_parse_host
        # $trace_states = true
        str = 'h'
        ap = Alt::URI::Gen::AuthParts.parse(str)
        assert_equal(str,ap.store[:host])
        assert_equal(str,ap.value)
        assert_equal(str,ap.to_s)
      end
      def test_parse_host_port
        # $trace_states = true
        h = 'h'
        port = 8080.to_s
        str = [h,port].join(':')
        ap = Alt::URI::Gen::AuthParts.parse(str)
        assert_equal(h,ap.store[:host])
        assert_equal(port,ap.store[:port])
        assert_equal(str,ap.to_s)
      end

      def test_parse_user_host
        # $trace_states = true
        h = 'h'
        u = 'waldo'
        str = [u,h].join('@')
        ap = Alt::URI::Gen::AuthParts.parse(str)
        assert_equal(h,ap.store[:host])

        ui = Alt::URI::Gen::UserInfoParts.parse(u)
        assert_equal(ui,ap.store[:userinfo])
        assert_equal(u,ap.userinfo)
        assert_equal(str,ap.to_s)
      end

      def test_assign_host
        # $trace_states = true
        ap = Alt::URI::Gen::AuthParts.new
        h = 'h'
        ap.host = h
        assert_equal(h,ap.store[:host])
        assert_equal(h,ap.to_s)
      end

      def test_assign_port
        # $trace_states = true
        ap = Alt::URI::Gen::AuthParts.new
        h = 'h'
        prt = 8888.to_s 
        ap.host = h
        ap.port = prt
        assert_equal(prt,ap.store[:port])
        assert_equal([h,prt].join(':'),ap.to_s)
      end

      def test_assign_user
        # $trace_states = true
        ap = Alt::URI::Gen::AuthParts.new
        h = 'h'
        u = 'waldo'
        ap.host = h
        ap.user = u
        assert_equal(u,ap.user)
        assert_equal([u,h].join('@'),ap.to_s)
      end
      def test_assign_user_password
        # $trace_states = true
        ap = Alt::URI::Gen::AuthParts.new
        h = 'h'
        u = 'waldo'
        passwd = 'emerson'
        ap.host = h
        ap.user = u
        ap.password = passwd
        assert_equal(u,ap.user)
        assert_equal(passwd,ap.password)
        assert_equal("#{u}@#{h}",ap.to_s)
      end

      def test_assign_user_empty_password
        # $trace_states = true
        ap = Alt::URI::Gen::AuthParts.new
        h = 'h'
        u = 'waldo'
        passwd = ''
        ap.host = h
        ap.user = u
        ap.password = passwd
        assert_equal(u,ap.user)
        assert_equal(passwd,ap.password)
        assert_equal("#{u}:@#{h}",ap.to_s)
      end


    end
    

  end
end



