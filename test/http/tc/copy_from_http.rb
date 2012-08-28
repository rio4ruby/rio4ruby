require 'rio'
require "test/unit"
require 'http/def'

module RIO::HTTP::UnitTest
  module CopyFromHTTP
    module Tests
      include RIO::HTTP::TestConst


      def cptest(src)
        dst = rio('dst').delete!.mkpath
        dst < src.clone
        assert_rios_equal(src.clone,rio(dst,src.filename),"rio copy")
      end

      def test_gunzip_uri_rio
        ans = rio(GZURL).gzip.contents
        exp = rio(GZFILE).gzip.contents
        assert_equal(exp,ans)
      end
      def test_gunzip_copy_uri_rio
        #p "copy_from_http: pwd=#{Dir.pwd}"
        ario = rio('out.txt').delete! < rio(GZURL).gzip
        ans = rio(ario).contents
        exp = rio(GZFILE).gzip.contents
        assert_equal(exp,ans)
      end

      def test_uri_rio_to_file
        ario = rio('outf').delete!.touch
        url = HWURL
        urio = rio(url)
        ario < urio
        exp = urio.contents
        assert_equal(exp,ario.contents)
        assert_equal(rio(HWFILE).contents,rio('outf').contents)
      end

      def test_uri_rio_to_file2
        ario = rio('outf2').delete!.touch
        url = HWURL
        urio = rio(url)
        urio > ario
        exp = urio.contents
        assert_equal(exp,ario.contents)
        assert_equal(rio(HWFILE).contents,rio('outf2').contents)
      end
      def test_uri_rio_to_filex
        ario = rio('outx').delete!
        url = HWURL
        urio = rio(url)
        ario < urio
        exp = urio.contents
        assert_equal(exp,ario.contents)
        assert_equal(rio(HWFILE).contents,rio('outx').contents)
      end
      def test_uri_rio_to_filex2
        ario = rio('outx2').delete!
        url = HWURL
        urio = rio(url)
        urio > ario
        exp = urio.contents
        assert_equal(exp,ario.contents)
        assert_equal(rio(HWFILE).contents,rio('outx2').contents)
      end
      def test_uri_rio_to_dir
        ario = rio('ud').delete!.mkdir
        url = HWURL
        urio = rio(url)
        ario < urio
        drio = rio(ario,urio.filename)
        assert(drio.file?)
        assert_equal(urio.contents,drio.contents)
        assert_equal(rio(HWFILE).contents,drio.contents)
      end
      def test_uri_rio_to_dir2
        ario = rio('ud2').delete!.mkdir
        url = HWURL
        urio = rio(url)
        urio > ario
        drio = rio(ario,urio.filename)
        assert(drio.file?)
        assert_equal(urio.contents,drio.contents)
        assert_equal(rio(HWFILE).contents,drio.contents)
      end
      def test_uri_string_to_dir
        ario = rio('uds').delete!.mkdir
        url = HWURL
        urio = rio(url)
        #$trace_states = true
        ario < url
        $trace_states = false
        drio = rio(ario,urio.filename)
        assert(drio.file?)
        assert(urio.contents,drio.contents)
      end
      def test_url_string_to_file
        ario = rio('out').delete!.touch
        url = HWURL
        ario < url
        exp = url
        assert_equal(exp,ario.contents)
      end
      def test_url_array_to_file
        ario = rio('out').delete!.touch
        url = HWURL
        ario < [url]
        exp = url
        assert_equal(exp,ario.contents)
      end
      def test_url_string_to_nonex
        ario = rio('outz').delete!
        url = HWURL
        ario < url
        exp = url
        assert_equal(exp,ario.contents)
      end




    end
    
  end
end

