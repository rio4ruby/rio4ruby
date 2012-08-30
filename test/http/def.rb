
module RIO::HTTP
  module TestConst
    RTHOST = ENV['RIO_TEST_HOST'] ||= 'localhost'
    RTPORT = ENV['RIO_TEST_PORT'] || 80
    RTHOSTPORT = "#{RTHOST}:#{RTPORT}"
    RTDIR = 'riotest'
    HWFILENAME = 'hw.html'
    GZFILENAME = 'lines.txt.gz'
    DRFILENAME = 'dir'
    HWURL = "http://#{RTHOSTPORT}/#{RTDIR}/#{HWFILENAME}"
    GZURL = "http://#{RTHOSTPORT}/#{RTDIR}/#{GZFILENAME}"
    DRURL = "http://#{RTHOSTPORT}/#{RTDIR}/#{DRFILENAME}"
    LOCALRTDIR = rio(rio(__FILE__).dirname,'../srv/www/htdocs',RTDIR)
    HWFILE = LOCALRTDIR/HWFILENAME
    GZFILE = LOCALRTDIR/GZFILENAME
    URLS = [HWURL,GZURL,DRURL]
  end
end

