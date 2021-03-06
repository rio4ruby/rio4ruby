#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require 'rio'
require 'tc/testcase'
require 'qpdir'

#require 'dev-utils/debug'

#require 'tc_myfirsttests'
#require 'tc_moretestsbyme'
#require 'ts_anothersetoftests'

class TC_RIO_misc < Test::Unit::TestCase
  def rio(*args) RIO.rio(*args) end
  def rootrio(*args) RIO.root(*args) end
  def ttdir() RIO.rio($QPDIR).mkpath end
  def assert_equal_s(a,b) assert_equal(a.to_s,b.to_s) end

  def test_iomodes
    exp = (0..5).to_a.map { |n| "Line #{n}" }
    f = rio($QPDIR,'rwlines.txt').chomp
    0.upto(4) do |n|
      f.puts("Line #{n}")
    end
    got =  f.a.puts("Line 5").readlines
    assert_equal(exp,got)

    f = rio($QPDIR,'rwlines.txt').mode('w')
    0.upto(4) { |n| f.puts("Line #{n}") }
    assert_raise(IOError) {
      f.readlines
    }

    f = rio($QPDIR,'rwlines.txt').a
    assert_equal_s('a',f.outputmode?)
    f.puts("Line 0\n\n")
#    assert_match(/Output$/,.handled_by)
    assert_equal_s('a',f.mode?)
    assert_equal("Line 0\n",f.rewind.gets);
    assert_equal_s('r',f.mode?)
#    assert_match(/Input$/,f.handled_by)

    f = rio($QPDIR,'rwlines.txt').a!
    assert_equal_s('a+',f.outputmode?)
    f.puts("Line 0\n\n")
#    assert_match(/InOut$/,f.puts("Line 0\n\n").handled_by)
    assert_equal_s('a+',f.mode?)
    assert_equal("Line 0\n",f.rewind.gets);
    assert_equal_s('a+',f.mode?)
#    assert_match(/InOut$/,f.handled_by)

    f = rio($QPDIR,'rwlines.txt').w
    assert_equal_s('w',f.outputmode?)
    f.puts("Line 0\n\n")
#    assert_match(/Output$/,f.puts("Line 0\n\n").handled_by)
    assert_equal_s('w',f.mode?)
    assert_equal("Line 0\n",f.rewind.gets);
    assert_equal_s('r',f.mode?)
#    assert_match(/Input$/,f.handled_by)

    f = rio($QPDIR,'rwlines.txt').w!
    assert_equal_s('w+',f.outputmode?)
    f.puts("Line 0").puts("Line 1")
#    assert_match(/InOut$/,f.puts("Line 0").puts("Line 1").handled_by)
    assert_equal_s('w+',f.mode?)
    assert_equal("Line 0\n",f.rewind.gets);
    assert_equal_s('w+',f.mode?)
#    assert_match(/InOut$/,f.handled_by)

    f = rio($QPDIR,'rwlines.txt').r
    assert_equal_s('r',f.inputmode?)
    f.puts("Line 0").puts("Line 1")
#    assert_match(/Output$/,f.puts("Line 0").puts("Line 1").handled_by)
    assert_equal_s('w',f.mode?)
    assert_equal("Line 0\n",f.rewind.gets);
    assert_equal_s('r',f.mode?)
#    assert_match(/Input$/,f.handled_by)

    f = rio($QPDIR,'rwlines.txt').r!
    assert_equal_s('r+',f.inputmode?)
    f.puts("Line 0").puts("Line 1")
#    assert_match(/InOut$/,f.puts("Line 0").puts("Line 1").handled_by)
    assert_equal_s('r+',f.mode?)
    assert_equal("Line 0\n",f.rewind.gets);
#    assert_match(/InOut$/,f.handled_by)
    assert_equal_s('r+',f.mode?)


  end

  def test_readwrite 
    require 'rio'
    tdir = rio($QPDIR,%w/test_readwrite/)
    tdir.rmtree.mkpath.chdir {
      exp = (0..5).to_a.map { |n| "Line #{n}" }

      f = rio('rwlines.txt').chomp
      0.upto(4) { |n| f.puts("Line #{n}") }
      got =  f.a.puts("Line 5").readlines
      assert_equal(exp,got)
      
      
      f = rio('rwlines.txt').a
      assert_equal_s('a',f.outputmode?)
      f.puts("Line 0\n\n")
#      assert_match(/Output$/,f.puts("Line 0\n\n").handled_by)
      assert_equal_s('a',f.mode?)
      assert_equal("Line 0\n",f.rewind.gets);
      assert_equal_s('r',f.mode?)
#      assert_match(/Input$/,f.handled_by)
      
      f = rio('rwlines.txt').a!
      assert_equal_s('a+',f.outputmode?)
      f.puts("Line 0\n\n")
#      assert_match(/InOut$/,f.puts("Line 0\n\n").handled_by)
      assert_equal_s('a+',f.mode?)
      assert_equal("Line 0\n",f.rewind.gets);
      assert_equal_s('a+',f.mode?)
#      assert_match(/InOut$/,f.handled_by)
      
      f = rio('rwlines.txt').w
      assert_equal_s('w',f.outputmode?)
      f.puts("Line 0\n\n")
#      assert_match(/Output$/,f.puts("Line 0\n\n").handled_by)
      assert_equal_s('w',f.mode?)
      assert_equal("Line 0\n",f.rewind.gets);
      assert_equal_s('r',f.mode?)
#      assert_match(/Input$/,f.handled_by)
      
      f = rio('rwlines.txt').w!
      assert_equal_s('w+',f.outputmode?)
      f.puts("Line 0").puts("Line 1")
#      assert_match(/InOut$/,f.puts("Line 0").puts("Line 1").handled_by)
      assert_equal_s('w+',f.mode?)
      assert_equal("Line 0\n",f.rewind.gets);
      assert_equal_s('w+',f.mode?)
#      assert_match(/InOut$/,f.handled_by)

      f = rio('rwlines.txt').r
      assert_equal_s('r',f.inputmode?)
      f.puts("Line 0").puts("Line 1")
#      assert_match(/Output$/,f.puts("Line 0").puts("Line 1").handled_by)
      assert_equal_s('w',f.mode?)
      assert_equal("Line 0\n",f.rewind.gets);
      assert_equal_s('r',f.mode?)
#      assert_match(/Input$/,f.handled_by)

      f = rio('rwlines.txt').r!
      assert_equal_s('r+',f.inputmode?)
      f.puts("Line 0").puts("Line 1")
#      assert_match(/InOut$/,f.puts("Line 0").puts("Line 1").handled_by)
      assert_equal_s('r+',f.mode?)
      assert_equal("Line 0\n",f.rewind.gets);
#      assert_match(/InOut$/,f.handled_by)
      assert_equal_s('r+',f.mode?)
    }
  end
  def test_copy2
    require 'rio'
    tdir = rio($QPDIR,%w/test_copy2/)
    tdir.rmtree.mkpath.chdir {
      txt = "Hello f1.txt"
      o = rio('o').puts(txt).close
      oslurp = o.contents

      n = rio('n')
      o.copy_to(n)
      assert_equal(oslurp,n.contents)

      d = rio('d1').rmtree.mkpath
      n = rio(d,'o')
      o.copy_to(d)
      assert_equal(oslurp,n.contents)

#      d = rio('d2').rmtree
#      n = rio(d,'o')
#      assert_raise(::RIO::Exception::Copy) {
#        o.copy_to(n)
#      }
      

      d = rio('d3').rmtree.mkpath
      n = rio(d,'o').touch
      o.copy_to(d)
      assert_equal(oslurp,n.contents)


      return unless $supports_symlink
      d = rio('d5').rmtree.mkpath
      q = rio(d,'qf').touch
      d.chdir {
        rio('qf').symlink('o')
      }
      n = rio(d,'o')
      o.copy_to(d)
      assert_equal(oslurp,n.contents)

      d = rio('d6').rmtree.mkpath
      q = rio(d,'qd').mkdir
      d.chdir {
        rio('qd').symlink('o')
      }
      n = rio(d,'o')




    }
  end
  def smap(a) a.map { |el| el.to_s } end
  def emap(d,a)
    exp = a.map { |f| File.join(d,f) }.sort
  end
  def gmap(io)
    smap(io.to_a).sort
  end

  def test_mkdir
    datadir = rio($QPDIR,'test_mkdir').rmtree.mkpath
    dir2 = rio(datadir,'dir2').rmtree.mkpath
    dir2 = rio(datadir,'dir2').rmtree.mkpath
    #     sd1 > dir2
    #     oline = rio(datadir,'dir1/sd1/f1.txt').readline
    #     nline = rio(datadir,'dir2/sd1/f1.txt').readline
    #     assert_equal(oline,nline)
    
    #     dir2 = rio(datadir,'dir2').rmtree.mkpath
    #     dir2 < sd1
    #     oline = rio(datadir,'dir1/sd1/f1.txt').readline
    #     nline = rio(datadir,'dir2/sd1/f1.txt').readline
    #     assert_equal(oline,nline)
    
  end
  def test_specialio
    tdir = rio(ttdir,'test_specialio').rmtree.mkpath
    msg = "Hello File\n"
    fname = 'f.txt'
    rio(tdir,fname).puts(msg).close
    str = rio(tdir,fname).readline
    assert_equal(msg,str)
    
#    require 'open3'

#    IO.popen("-") {|f| 
#      if f.nil?
#        rio(?-).puts('Hello Stdout')
#      else
#        assert_equal("Hello Stdout\n",f.gets)
#      end
#    }
    
    # For some reason the use of popen3 stopped working FIXME
    #    stdin,stdout,stderr = Open3.popen3(%q~ruby -e "require 'rio';rio(?=).puts('Hello Stderr')"~)
    #errput = stderr.gets
    #assert_equal("Hello Stderr\n",errput)
                 
    smsg = str.sub(/File/,'StringIO')
    srio = rio(?$).print(smsg)
    assert_equal(smsg,srio.string)
    # lines = rio('?').mode('w+').puts(str.sub(/File/,'Tempfile')).readlines
    
  end

  def cmpfiles(z1,z2)
    o = rio(z1).contents
    n = rio(z2).contents
    o == n
  end

  def test_path
    RIO.cwd.chdir do 
      dir =  rio($QPDIR,%w/test_path/).rmtree.mkpath
      s_dir = dir.to_s
      
      assert_equal(true,::FileTest.directory?(s_dir))
      f1 = RIO.rio(dir,'f1.txt').puts("This is f1")
      assert_equal(true,::FileTest.file?(::File.join(s_dir,'f1.txt')))
      f2 = RIO.rio(dir,'f2.txt').puts("This is f2")
      assert_equal(true,::FileTest.file?(::File.join(s_dir,'f2.txt')))
      f3 = RIO.rio(dir,'d1').mkpath.join('f3.txt').puts("This is f2")
      assert_equal(true,::FileTest.directory?(::File.join(s_dir,'d1')))
      assert_equal(true,::FileTest.file?(::File.join(s_dir,'d1/f3.txt')))
      f4 = RIO.rio(dir,'d1').mkpath.join('f4.emp').touch
      assert_equal(0,::FileTest.size(::File.join(s_dir,'d1/f4.emp')))
    end
  end
end
