#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require 'rio'
require 'uri'
require 'test/unit'
require 'tc/testcase'
#require 'test/unit/testsuite'
require 'qpdir'

class TC_RIO_abs2 < Test::RIO::TestCase

  def test_abs10
    io = RIO.root/'tmp'
    assert_kind_of(RIO::Rio,io)
    assert_equal('/tmp',io.to_s)
  
  end

  def test_abs_localhost_slash_uri
    hdurl = 'http://localhost/'
    hduri = ::URI.parse(hdurl)
    hd = rio(hduri)
    assert_equal('/',hd.path)
    assert_equal('/',hd.fspath)
    assert_equal('http',hd.scheme)    
    assert_equal('localhost',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_url)
  end

  def test_abs_localhost_slash_string
    hdurl = 'http://localhost/'
    hd = rio(hdurl)
    assert_equal('/',hd.path)
    assert_equal('/',hd.fspath)
    assert_equal('http',hd.scheme)    
    assert_equal('localhost',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_url)

  end

  def test_abs_localhost_noslash_uri
    hdurl = 'http://localhost'
    hduri = ::URI.parse(hdurl)
    hd = rio(hduri)
    assert_equal('',hd.path)
    assert_equal('',hd.fspath)
    assert_equal('http',hd.scheme)    
    assert_equal('localhost',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_url)

  end

  def test_abs_localhost_noslash_string
    hdurl = 'http://localhost'
    hd = rio(hdurl)
    assert_equal('',hd.path)
    assert_equal('',hd.fspath)
    assert_equal('http',hd.scheme)    
    assert_equal('localhost',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_url)

  end

  def test_abs_localhost_path_string
    hdurl = 'http://localhost/rio/hw.html'
    hd = rio(hdurl)
    assert_equal('/rio/hw.html',hd.path)
    assert_equal('/rio/hw.html',hd.fspath)
    assert_equal('http',hd.scheme)    
    assert_equal('localhost',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_url)

  end

  def test_abs_nohost_root_path_uri
    hdurl = 'file:///'
    hduri = ::URI.parse(hdurl)
    # puts hduri
    hd = rio(hduri)
    assert_equal('/',hd.path)
    assert_equal('/',hd.fspath)
    assert_equal('file',hd.scheme)    
    assert_equal('',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.to_url)
    assert_equal(hdurl,hd.abs.to_url)

  end
  def test_abs_nohost_root_path_string
    hdurl = 'file:///'
    hd = rio(hdurl)
    assert_equal('/',hd.path)
    assert_equal('/',hd.fspath)
    assert_equal('file',hd.scheme)    
    assert_equal('',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.to_url)
    assert_equal(hdurl,hd.abs.to_url)

  end
  def test_abs_nohost_noscheme_root_path_string
    hdurl = '/'
    hd = rio(hdurl)
    assert_equal('/',hd.path)
    assert_equal('/',hd.fspath)
    assert_equal('file',hd.scheme)    
    assert_equal('',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_s)
    assert_equal('file:///',hd.to_url)
    assert_equal('file:///',hd.abs.to_url)
    require 'tmpdir'

  end
  def test_abs_tmp_noslash
    hdurl = '/tmp'
    hdurl = '/WINDOWS' unless FileTest.directory?(hdurl)
    hd = rio(hdurl)
    #      assert_equal(hdurl+'/',hd.path)
    assert_equal(hdurl,hd.fspath)
    assert_equal('file',hd.scheme)    
    assert_equal('',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_s)
    #     assert_equal('file://'+hdurl+'/',hd.to_url)
    #     assert_equal('file://'+hdurl+'/',hd.abs.to_url)

  end
  def test_abs_tmp_slash
    hdurl = '/tmp/'
    hd = rio(hdurl)
    assert_equal('/tmp/',hd.path)
    assert_equal('/tmp/',hd.fspath)
    assert_equal('file',hd.scheme)    
    assert_equal('',hd.host)
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_s)
    assert_equal('file:///tmp/',hd.to_url)
    assert_equal('file:///tmp/',hd.abs.to_url)

  end
  def test_abs2
    hdurl = $QPDIR
    hd = rio(hdurl)
    assert_equal($QPDIR,hd.path)
    assert_equal($QPDIR,hd.fspath)
    #assert_equal('path',hd.scheme)    
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.path.to_s)
  end

  def test_abs3
    hdurl = $QPDIR
    hd = rio(hdurl)
    #      assert_equal($QPDIR,hd.path)
    assert_equal($QPDIR,hd.fspath)
    #assert_equal('path',hd.scheme)    
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_s)

  end
  def test_abs4
    hdurl = $QPDIR
    hd = rio(hdurl)
    assert_equal($QPDIR,hd.path)
    assert_equal($QPDIR,hd.fspath)
    #assert_equal('path',hd.scheme)    
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_s)

  end
  def test_abs5
    hdurl = $QPDIR
    hd = rio(hdurl)
    assert_equal($QPDIR,hd.path)
    assert_equal($QPDIR,hd.fspath)
    #assert_equal('path',hd.scheme)    
    assert_equal(true,hd.abs?)
    assert_equal(true,hd.absolute?)
    assert_equal(hdurl,hd.abs.to_s)

  end
  def test_abs6
    io = RIO.root
    assert_kind_of(RIO::Rio,io)
    assert_equal('/',io.to_s)


  end
  def test_abs7
    z = RIO.rio(RIO.root,%w/tmp zippy/)
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)


  end
  def test_abs8
    io = RIO.cwd
    assert_kind_of(RIO::Rio,io)
    cwd = ::Dir.getwd
    assert_equal(cwd,io.path)

  end
  def test_abs9
    io = RIO.cwd
    assert_kind_of(RIO::Rio,io)
    cwd = ::Dir.getwd
    assert_equal(cwd,io.to_s)

  end
  def test_abs11
    tmp = RIO.root('tmp')
    assert_kind_of(RIO::Rio,tmp)
    assert_equal('/tmp',tmp.to_s)
    
  end
  def test_abs12
    tmp = RIO.root('tmp')
    z = tmp.join('zippy')
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)

  end
  def test_abs13
    tmp = RIO.root('tmp')
    z = tmp/'zippy'
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)

  end
  def test_abs14
    z = RIO.rio('/tmp/zippy')
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)
    
  end
  def test_abs15
    tmp = RIO.root('tmp')
    z = RIO.rio(tmp,'zippy')
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)

  end
  def test_abs16
    z = RIO.rio(RIO.root,%w/tmp zippy/)
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)

  end
  def test_abs17
    tmp = RIO.root('tmp')
    z = RIO.rio(tmp)/'zippy'
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)

  end
  def test_abs18
    z = rio('/tmp/zippy')
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)
    
  end
  def test_abs19
    tmp = RIO.root('tmp')
    z = rio(tmp,'zippy')
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)

  end
  def test_abs20
    z = rio(RIO.root,%w/tmp zippy/)
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)

  end
  def test_abs21
    tmp = RIO.root('tmp')
    z = rio(tmp).join('zippy')
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy',z.to_s)

  end
  def test_abs22
    z = rio(::Alt::URI.parse('zippy/f.html'))
    assert_kind_of(RIO::Rio,z)
    assert_equal('zippy/f.html',z.to_s)

  end
  def test_abs23
    z = rio(::Alt::URI.parse("file:///tmp/zippy/f.html"))
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy/f.html',z.to_s)

  end
  def test_abs24
    z = rio("file:///tmp/zippy/f.html")
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy/f.html',z.to_s)

  end
  def test_abs25
    z = rio("file:///tmp/","zippy/f.html")
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy/f.html',z.to_s)
  end

  def test_abs26
    u = URI('zippy/f.html')

    z = rio("file:///tmp/",u)
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy/f.html',z.to_s)

  end

  def test_abs27
    u = URI('zippy/f.html')
    z = rio("file:///tmp/",RIO::RRL::Builder.build(u))
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy/f.html',z.to_s)

  end
  def test_abs28
    u = URI('zippy/f.html')
    z = rio("file:///tmp/",rio(u))
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy/f.html',z.to_s)

  end
  def test_abs29
    u = URI('zippy/f.html')
    z = rio("/tmp",rio(u))
    assert_kind_of(RIO::Rio,z)
    assert_equal('/tmp/zippy/f.html',z.to_s)
  end
end

