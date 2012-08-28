#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'

class TC_strio < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true
  end
  def setup()
    super
  end

  def test_new
    # $trace_states = true
    sio = rio(:"")
    assert_equal('strio',sio.scheme)
  end

  def test_new_anonymous
    #$trace_states = true
    smsg = "Hello String\n"
    sio = rio(:"")
    sio.puts!(smsg)
    assert_equal(smsg,sio.string)
    ans = sio.gets
    assert_equal(smsg,ans)
  end

  def test_new_string
    # $trace_states = true
    smsg = "Hello String\n" 
    sio = rio(:"",smsg)
    assert_equal(smsg,sio.string)
    ans = sio.gets
    assert_equal(smsg,ans)
  end

  def test_new_stringio
    # $trace_states = true
    smsg = "Hello StringIO\n"
    strio = StringIO.new
    strio.puts(smsg)
    sio = rio(strio)
    assert_equal(smsg,sio.string)
    ans = sio.gets
    assert_equal(smsg,ans)
    smsg2 = "Hello Changed\n"
    sio.puts(smsg2)
    ans = sio.gets
    assert_equal(smsg2,ans)

  end

  def test_copy
    str = "Hello World\n"
    src = rio(:"").print!(str)
    ans = rio(:"")
    
    ans.string = ""
    rio(:"") < src > ans
    assert_equal(str,ans.string)
  end




end
