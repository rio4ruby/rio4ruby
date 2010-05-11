# -*- coding: utf-8 -*-



# encoding: UTF-8
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
#require "test/unit"
require 'rio/alturi'

module Alt::URI::UnitTest
  module Enc
    module Tests
      def test_initialize
        pth = "file://ahost/a/b/c"
        u = Alt::URI.parse(pth)
        assert_equal('US-ASCII',u.to_s.encoding.name)
      end
      def test_create
        pstr = "/mp3/J. S. Bach - Orgelwerke - Karl Richter/35 - Sei gegrüßet, Jesu gütig - BWV 768.flac"
        #p pstr.encoding
        u = Alt::URI.create(:scheme => 'ftp', 
                        :host => 'localhost',
                        :path => pstr)

        assert_equal('US-ASCII',u.to_s.encoding.name)
        assert_equal('UTF-8',u.path.encoding.name)
      end
      def test_uri_assign
        u = Alt::URI.create(:scheme => 'http')

        u.uri = "http://localhost/mp3/J.%20S.%20Bach%20-%20Orgelwerke%20-%20Karl%20Richter/35%20-%20Sei%20gegr%c3%bc%c3%9fet,%20Jesu%20g%c3%bctig%20-%20BWV%20768.flac"
        assert_equal('US-ASCII',u.to_s.encoding.name)
        assert_equal('UTF-8',u.path.encoding.name)

      end
      def test_check_paths
        testdir = rio('../../../rio/test/')
        testdir.chdir do 
          r = rio('data/filelist.txt').enc('UTF-8').chomp
          paths = r.map{|el| el.sub(%r{^/loc},'')}
          lines = rio('data/linklist.txt').chomp[]
          urls = lines.map{|el| Alt::URI.parse(el) }
          #upaths = urls.map{|u| u.path.force_encoding("UTF-8")}
          upaths = urls.map{|u| u.path}
          assert_equal(paths,upaths)
        end
      end

      def test_enc
        ustr = "http://localhost/mp3/J.%20S.%20Bach%20-%20Orgelwerke%20-%20Karl%20Richter/35%20-%20Sei%20gegr%c3%bc%c3%9fet,%20Jesu%20g%c3%bctig%20-%20BWV%20768.flac"
        pstr = "/mp3/J. S. Bach - Orgelwerke - Karl Richter/35 - Sei gegrüßet, Jesu gütig - BWV 768.flac"
        r = rio(ustr)
        pth = r.path
        assert_equal('UTF-8',pth.encoding.name)
        assert_equal(pstr,pth)
      end

      def xtest_check_read_urls
        #p __ENCODING__
        testdir = rio('../../../rio/test/')
        testdir.chdir do 
          links = rio('data/linklist.txt').chomp[]
          r0 = rio(links[0])
          p r0.contents.size
          files = rio('data/filelist.txt').chomp[]
          p files
          f0 = rio(files[0])
          p f0
          $trace_states = true
          p f0.read.size

        end
      end

      def test_ls
        #p __ENCODING__
        rootdir = rio('/loc/mp3')
        out = rio('filelist.txt').encoding('UTF-8')
        #out = rio(:-)
        rio(rootdir).all do |ent|
          #p ent.path
          out.puts(ent.path)
        end
        out.close
      end
      def test_links
        #p __ENCODING__
        rootdir = rio('/loc/mp3')
        out = rio('linklist.txt').touch
        #out = rio(:-)
        rio(rootdir).all do |ent|
          #p ent.path
          u = Alt::URI.create(:scheme => 'http',:host => 'localhost',
                              :path => ent.path.sub(%r{^/loc/},'/'))
          out.puts(u.to_s)
        end
        out.close
      end
      def test_string
        #p __ENCODING__
        str = "There you go again\u2026"
        #p str
      end
    end
  end
end
