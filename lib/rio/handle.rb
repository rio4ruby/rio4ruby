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


require 'rio/base'

module RIO
  class Handle < Base #:nodoc: all
    attr_accessor :target
    def initialize(st=nil) 
      @target = st 
    end
    def initialize_copy(*args)
      #p callstr('initialize_copy',*args)
      super
      @target = @target.clone
    end
    def method_missing(sym,*args,&block)
      #  p callstr('method_missing',*args)
      @target.__send__(sym,*args,&block)
    end
    def t_instance_of?(*args) @target.instance_of?(*args) end
    def t_kind_of?(*args) @target.kind_of?(*args) end
    def t_class(*args) @target.class(*args) end
    def to_s() @target.to_s() end
    def split(*args,&block) @target.split(*args,&block) end
    def callstr(func,*args)
      self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
    end
  end
end

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__
