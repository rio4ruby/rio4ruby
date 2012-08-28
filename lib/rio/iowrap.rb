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


#require 'fileutils'

module RIO
  module IOWrap #:nodoc: all
    class Base
      attr :ios
      def initialize(ios)
        @ios = ios
      end
      def initialize_copy(other)
        super
        @ios = other.ios.clone unless other.ios.nil?
      end
      def callstr(func,*args)
        self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
      end
      def handle() @ios end
      def open?() not closed? end
    end
    class Stream < Base
      attr_reader :eof
      def initialize(ios)
        @eof = false
        @closed = false
        super
      end
      def close()
        @closed = true
        handle.close 
      end
      def closed?() 
        @closed
      end
      def eof?() @eof end

      def each(*args,&block)
        rtn = handle.each(*args,&block)
        @eof = true
        rtn
      end
      alias :each_line :each
      def gets(*args)
        @eof = true unless ans = handle.gets(*args)
        ans
      end
      def getc(*args)
        @eof = true unless ans = handle.getc(*args)
        ans
      end
      def readlines(*args)
        rtn = handle.readlines(*args)
        @eof = true
        rtn
      end
      def readline(*args)
        begin
          return handle.readline
        rescue EOFError
          @eof = true
          raise
        end
      end
      def read(*args)
        @eof = true unless ans = handle.read(*args)
        ans
      end
      def sysread(*args)
        @eof = true unless ans = handle.sysread(*args)
        ans
      end
#       extend Forwardable
#       def_instance_delegators(:handle,
#                               :binmode,
#                               :stat,
#                               :rewind,
#                               :<<,:print,:printf,:puts,:putc,:write,:syswrite,
#                               :pos,:pos=,:lineno,:lineno=,
#                               :fileno,
#                               :close_read,:close_write,
#                               :fsync,:sync,:sync=,:fcntl,:ioctl)

      #def puts(*args)
      #  handle.puts(*args)
      #end
      def method_missing(sym,*args,&block)
        #p callstr('method_missing',sym,*args)
        handle.__send__(sym,*args,&block)
      end
    end
  end
end
__END__
