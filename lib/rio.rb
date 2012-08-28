#--
# ===========================================================================
# Copyright (c) 2005,2006,2007,2008,2009,2010 Christopher Kleckner
# All rights reserved
#
# This file is part of the Rio library for ruby.
#
# Rio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Rio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rio; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# =========================================================================== 
#++
#
#
# ==== Rio - Ruby I/O Facilitator
#
# Rio is a facade for most of the standard ruby classes that deal with
# I/O; providing a simple, intuitive, succinct interface to the
# functionality provided by IO, File, Dir, Pathname, FileUtils,
# Tempfile, StringIO, OpenURI and others. Rio also provides an
# application level interface which allows many common I/O idioms to be
# expressed succinctly.
#
# ===== Suggested Reading
#
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#
# Project::       http://rubyforge.org/projects/rio/
# Documentation:: http://rio4ruby.com/
# Bugs::          http://rubyforge.org/tracker/?group_id=821
# Blog::          http://rio4ruby.blogspot.com/
# Email::         rio4ruby@rubyforge.org
#

require 'rio/version'
unless RUBY_VERSION > "1.9"
  raise LoadError, "This version of Rio(#{RIO::VERSION}) requires Ruby 1.9+. Ruby version is #{RUBY_VERSION}"
end
#FS_ENCODING = Dir.pwd.encoding
#p "FS_ENCODING=#{FS_ENCODING}"

begin
  ENV['TMPDIR'] ||= '/tmp' if (RUBY_PLATFORM =~ /cygwin/)
end

require 'rio/fs'
#require 'rio/def'
#require 'rio/exception'

require 'forwardable'

$trace_states = false

require 'rio/kernel'
require 'rio/constructor'
require 'rio/construct'

require 'rio/const'
require 'rio/local'
require 'rio/factory'

module RIO
  class Rio #:doc:
    include Local
    protected

    attr_reader :state

    public

    # See RIO.rio
    def initialize(*args)
      if args[0].instance_of? RIO::Handle
        @state = args[0]
      else
        @state = Factory.instance.create_state(*args)
      end
    end

    def initialize_copy(*args)
      super
      @state = Factory.instance.clone_state(@state)
    end

    # See RIO.rio
    def self.rio(*args,&block) # :yields: self
      ario = new(*args)
      if block_given?
        old_closeoncopy = ario.closeoncopy?
        begin
          yield ario.nocloseoncopy
        ensure
          ario.reset.closeoncopy(old_closeoncopy)
        end
      end
      ario
    end

    # Returns the string representation of a Rio that is used by Ruby's libraries.
    # For Rios that exist on the file system this is Rio#fspath.
    # For FTP and HTTP Rios, this is the URL.
    #
    #  rio('/a/b/c').to_s                    ==> "/a/b/c"
    #  rio('b/c').to_s                       ==> "b/c"
    #  rio('C:/b/c').to_s                    ==> "C:/b/c"
    #  rio('//ahost/a/b').to_s               ==> "//ahost/a/b"
    #  rio('file://ahost/a/b').to_s          ==> "//ahost/a/b"
    #  rio('file:///a/b').to_s               ==> "/a/b"
    #  rio('file://localhost/a/b').to_s      ==> "/a/b"
    #  rio('http://ahost/index.html').to_s   ==> "http://ahost/index.html"
    #
    def to_s() target.to_s end

    alias :to_str :to_s
    def dup
      #p callstr('dup',self)
      self.class.new(self.rl)
    end
    

    # Returns the length of the Rio's String representation
    # 
    # To get the size of the underlying file system object use RIO::IF::Test#size
    def length() target.length end

    # Equality - calls to_s on _other_ and compares its return value 
    # with the value returned by Rio#to_s
    def ==(other) 
      begin
        target == other.to_str
      rescue NoMethodError
        target == other.to_s
      end
    end

    # Equality (for case statements) same as Rio#==
    def ===(other) self == other end

    # Comparison for sorting; compare as strings.
    def <=>(other) self.to_str <=> other.to_str end

    # Rios are hashed based on their String representation
    def hash() self.to_str.hash end

    # Returns true if their String representations are eql?
    #def eql?(other) self.eql?(other) end

    # Match - invokes _other_.=~, passing the value returned by Rio#to_str
    def =~(other) other =~ self.to_str end

    def method_missing(sym,*args,&block) #:nodoc:
      # p callstr('method_missing',sym,*args)
      
      result = target.__send__(sym,*args,&block)
      return result unless result.kind_of? State::Base and result.equal? target
      
      self
    end
    
    def inspect()
      cl = self.class.to_s[5..-1]
      st = state.target.class.to_s[5..-1]
      sprintf('#<%s:0x%x:"%s" (%s)>',cl,self.object_id,self.to_url,st)
    end
    

    protected

    def target()  #:nodoc:
      @state.target 
    end

    def callstr(func,*args) #:nodoc:
      self.class.to_s+'.'+func.to_s+'('+args.join(',')+')'
    end

  end # class Rio
end # module RIO
module RIO
  class Rio
    USE_IF = true #:nodoc:
    
    if USE_IF
      include Enumerable
     require 'rio/if'
      include RIO::IF::Grande
      require 'rio/ext/if'
      include RIO::IF::Ext
    end
  end
end

#require 'rio/ext/zipfile.rb'

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__

puts
puts("Run the tests that came with the distribution")
puts("From the distribution directory use 'test/runtests.rb'")
puts
