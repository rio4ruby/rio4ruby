$:.unshift File.expand_path(File.dirname(__FILE__)+'/../../lib/')
require 'rio'
p RUBY_VERSION
p RIO::VERSION
puts

#r = rio("ftp://ftp.rio4ruby.com","riotest@rio4ruby.com","riotest")
#r = rio("ftp:","ftp.rio4ruby.com","riotest@rio4ruby.com","riotest")
#r = rio("ftp://kleckner:Zippy6167@ftp.rio4ruby.com")
#r = rio("ftp://ftp.gnu.org/pub/")
r = rio("file:///home/kit")

p r
r.entries do |ent|
  p ent
end
  



#x = rio('/loc/dev/rio/README');
#p x[]
#p x.to_a
  


if __FILE__ == $0
  # TODO Generated stub
end