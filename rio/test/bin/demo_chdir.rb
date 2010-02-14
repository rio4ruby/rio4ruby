$:.unshift File.expand_path(File.dirname(__FILE__)+'/../../lib/')
require 'rio'

p "[#{RUBY_PLATFORM}] - Ruby(#{RUBY_VERSION}) - Rio(#{RIO::VERSION})"

puts rio("/loc/mp3","Beethoven","Alfred Brendel").entries[]



__END__
rio("http://rio4ruby.com/index.php") > rio("howdy.php")





__END__

require 'tmpdir'
require 'tempfile'
prefix = 'rio'
tdir = ::Dir::tmpdir
p tdir
tf = ::Tempfile.new( prefix.to_s, tdir.to_s)
p tf
pth =  tf.path
p pth
pth.gsub!("\\","/")
p pth


puts
p rio(:temp)
puts
tmp = rio('temp:zippy').file
p tmp
p tmp.filename.to_s
tmp.close

puts
$trace_states = true

module TestMod
  class TestClass
  end
end
p TestMod::TestClass.ancestors


#p RIO::State::Base.ancestors

#x = rio(" mkpath_test1").mkpath
#p x
#p x.exist?
  


if __FILE__ == $0
  # TODO Generated stub
end