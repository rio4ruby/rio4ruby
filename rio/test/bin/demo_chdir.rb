$:.unshift File.expand_path(File.dirname(__FILE__)+'/../../lib/')
require 'rio'
p RUBY_VERSION
p RIO::VERSION
puts

x = rio('/loc/dev/rio/README');
p x[]
p x.to_a
  


if __FILE__ == $0
  # TODO Generated stub
end