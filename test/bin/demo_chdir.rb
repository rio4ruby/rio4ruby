$:.unshift File.expand_path(File.dirname(__FILE__)+'/../../lib/')
require 'rio'
p RUBY_VERSION
p RIO::VERSION

rio('/loc/dev/rio/').chdir {
  p Dir.pwd;
}
rio('/loc/dev/rio/').chdir { |d|
  p d;
}



if __FILE__ == $0
  # TODO Generated stub
end