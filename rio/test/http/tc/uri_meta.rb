require 'rio'
require "test/unit"
require 'http/def'

module RIO::HTTP::UnitTest
  module URIMeta
    module Tests
      include RIO::HTTP::TestConst

      def check_meta(r)
        f = open(r.to_url)
        [:content_type,:charset,:base_uri,:content_encoding,:last_modified].each do |sym|
          exp = f.__send__(sym)
          ans = r.__send__(sym)
          assert_equal(exp,ans)
        end
      end
      
      def test_meta_new()
        URLS.each do |url|
          check_meta(rio(url))
        end
      end

      def test_meta_open()
        URLS.each do |url|
          check_meta(rio(url).open('r'))
        end
      end

      def test_meta_read()
        URLS.each do |url|
          r = rio(url)
          contents = r.contents
          check_meta(r)
        end
      end

      def test_meta_read_some()
        URLS.each do |url|
          r = rio(url)
          str = r.gets
          check_meta(r)
        end
      end


    end
    
  end
end

