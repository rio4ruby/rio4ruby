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

      def test_new
        # $trace_states = true
        ui = Alt::URI::Gen::UserInfoParts.new
        assert(ui.store.empty?)
      end

      def test_parse_nil
        # $trace_states = true
        ui = Alt::URI::Gen::UserInfoParts.parse(nil)
        assert(ui.store.empty?)
      end

      def test_parse_simple_user_string
        # $trace_states = true
        ustr = 'waldo'
        ui = Alt::URI::Gen::UserInfoParts.parse(ustr)
        assert_equal(ustr,ui.store[:user])
      end

      def test_parse_simple_user_passwd_string
        # $trace_states = true
        
        ustr = 'waldo'
        pstr = 'pond'
        str = [ustr,pstr].join(':')
        ui = Alt::URI::Gen::UserInfoParts.parse(str)
        assert_equal(ustr,ui.store[:user])
        assert_equal(pstr,ui.store[:password])
      end

      def test_parse_esc_user_passwd_string
        # $trace_states = true
        
        ustr = 'waldo%40pond.org'
        pstr = 'emerson'
        str = [ustr,pstr].join(':')
        ui = Alt::URI::Gen::UserInfoParts.parse(str)
        assert_equal(ustr,ui.store[:user])
        assert_equal(pstr,ui.store[:password])
      end

      def test_parse_simple_user_esc_passwd_string
        # $trace_states = true
        
        ustr = 'waldo'
        pstr = 'at@colon:slash/question?hash#'
        str = [ustr,pstr].join(':')
        ui = Alt::URI::Gen::UserInfoParts.parse(str)
        assert_equal(ustr.sub(/@/,'%40'),ui.store[:user])
        assert_equal(pstr,ui.store[:password])
        assert_equal(ustr,ui.to_s)
      end

      def test_parse_esc_user_string
        # $trace_states = true
        ustr = 'waldo%40pond.org'
        ui = Alt::URI::Gen::UserInfoParts.parse(ustr)
        assert_equal(ustr,ui.store[:user])
      end

      def test_assign_esc_user
        # $trace_states = true
        ustr = 'waldo@pond.org'
        ui = Alt::URI::Gen::UserInfoParts.new
        ui.user = ustr
        assert_equal(ustr.sub(/@/,'%40'),ui.store[:user])
        assert_equal(ustr,ui.user)
      end

      def test_assign_simple_user
        # $trace_states = true
        ustr = 'waldo'
        ui = Alt::URI::Gen::UserInfoParts.new
        ui.user = ustr
        assert_equal(ustr,ui.store[:user])
        assert_equal(ustr,ui.user)
      end

      def test_assign_password
        # $trace_states = true
        ustr = 'waldo'
        pstr = 'emerson'
        ui = Alt::URI::Gen::UserInfoParts.parse(ustr)
        ui.password = pstr
        assert_equal(ustr,ui.store[:user])
        assert_equal(ustr,ui.user)
        assert_equal(pstr,ui.store[:password])
        assert_equal(pstr,ui.password)
        assert_equal(ustr,ui.to_s)
      end

      def test_assign_password_empty
        # $trace_states = true
        ustr = 'waldo'
        pstr = ''
        ui = Alt::URI::Gen::UserInfoParts.parse(ustr)
        ui.password = pstr
        assert_equal(ustr,ui.store[:user])
        assert_equal(ustr,ui.user)
        assert_equal(pstr,ui.store[:password])
        assert_equal(pstr,ui.password)
        assert_equal(ustr+':',ui.to_s)
      end


      def test_assign_password_nil
        # $trace_states = true
        ustr = 'waldo'
        pstr = nil
        ui = Alt::URI::Gen::UserInfoParts.parse(ustr)
        ui.password = pstr
        assert_equal(ustr,ui.store[:user])
        assert_equal(ustr,ui.user)
        assert_equal(pstr,ui.store[:password])
        assert_equal(pstr,ui.password)
        assert_equal(ustr,ui.to_s)
      end




    end
    
    class TestCase < Test::Unit::TestCase
      include Tests
    end

  end
end



