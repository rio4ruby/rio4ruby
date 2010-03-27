
module RIO
  module TC
    module Scheme
      def test_scheme_localhost_slash
        hdurl = 'http://localhost/'
        hd = rio(hdurl)
        assert_equal('http',hd.scheme)    
      end
      def test_slash
        hdurl = '/'
        hd = rio(hdurl)
        assert_nil(hd.scheme)    
      end
      def test_adir
        hdurl = '/adir'
        hd = rio(hdurl)
        assert_nil(hd.scheme)    
      end
      def test_netpath_w_path
        hdurl = '//ahost/'
        hd = rio(hdurl)
        assert_equal('file',hd.scheme)    
      end
      def test_netpath_no_path
        hdurl = '//ahost'
        hd = rio(hdurl)
        assert_equal('file',hd.scheme)    
      end
    end
  end

end
module RIO
  module TC
    module Host
      def test_localhost
        hdurl = 'http://localhost/'
        hd = rio(hdurl)
        assert_equal('localhost',hd.host)    
      end
      def test_nohost
        hdurl = '/'
        hd = rio(hdurl)
        assert_nil(hd.host)    
      end
      def test_netpath_w_path
        hdurl = '//ahost/'
        hd = rio(hdurl)
        assert_equal('ahost',hd.host)    
      end
      def test_netpath_no_path
        hdurl = '//ahost'
        hd = rio(hdurl)
        assert_equal('ahost',hd.host)    
      end
    end
  end

end

