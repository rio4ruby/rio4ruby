#--
# ===========================================================================
# Copyright (c) 2005-2012 Christopher Kleckner
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



require 'rio/abstract_method'

module RIO
  module Mode #:nodoc: all
    class Base
      attr_reader :mode
      protected :mode
      
      def initialize(arg)
        if arg.kind_of? self.class
          copy(arg)
        else
          @mode = arg
        end
      end
      
      def copy(other)
        @mode = other.mode
      end
      
      def to_s() @mode.to_s end

      abstract_method :primarily_read?, :primarily_write?, :allows_both?, :creates?

      def read_only?()
        allows_read? and !allows_write?
      end
      def write_only?()
        !allows_read? and allows_read?
      end
      def allows_read?()
        primarily_read? or allows_both?
      end
      def allows_write?()
        primarily_write? or allows_both?
      end
      extend Forwardable
      def_instance_delegators(:@mode,:=~,:==,:===)
    end
  end
  module Mode
    module StrMethods
      def primarily_read?() @mode[0,1] == 'r' end
      def primarily_write?() @mode[0,1] == 'w' or primarily_append? end
      def primarily_append?() @mode[0,1] == 'a' end
      def allows_both?() @mode[-1,1] == '+' end
      def creates?() primarily_append? || primarily_write? end
    end
    class Str < Base
      include StrMethods
    end
  end
  module Mode
    class Int < Base
      def primarily_read?() 
#        (@mode&File::RDONLY || (@mode&File::RDWR && ~(@mode&File::TRUNC)))
      end
      def primarily_write?() 
#        @mode&File::WRONLY || (@mode&File::RDWR && @mode&File::TRUNC) || primarily_append? 
      end
      def primarily_append?() 
#        @mode&File::APPEND
      end
      def allows_both?()
#        @mode[1,-1] == '+'
      end
      def creates?() 
        # primarily_append? || primarily_write? 
      end
    end
  end
end
