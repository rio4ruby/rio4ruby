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


#require 'rio/exception'
require 'fileutils'
module RIO
  module Impl
    module U
      def self.mv(s,d)
        ::FileUtils.mv(s.to_s,d.to_s)
      end
      def self.chmod(mod,s)
        ::File.chmod(mod,s.to_s)
      end
      def self.chown(owner_int,group_int,s)
        ::File.chown(owner_int,group_int,s.to_s)
      end
    end
  end
  module Ops
    module FileOrDir
      module ExistOrNot
      end
      module NonExisting
        include ExistOrNot
        def empty?() false end
      end

      module Existing
        include ExistOrNot

        def chmod(mod) rtn_self { fs.chmod(mod,fspath) } end
        def chown(owner,group) rtn_self { fs.chown(owner,group,fspath) } end
        def must_exist() self end

        def rename(*args,&block)
          if args.empty?
            softreset.rename(*args,&block)
          else
            rtn_reset { 
              dst = args.shift.to_s
              #p "rename: #{self} => #{dst}"
              fs.mv(uri.path,dst,*args) unless uri.path == dst
            } 
          end
        end
        def rename!(*args,&block)
          if args.empty?
            softreset.rename(*args,&block)
          else
            rtn_reset { 
              cpath = uri.path
              uri.path = args.shift.to_s
              #p "rename!: #{cpath} => #{uri.path}"
              fs.mv(cpath,uri.path,*args) unless uri.path == cpath
            } 
          end
        end
        alias :mv :rename
        def dirname=(arg)
          dst = ::Alt::URI.create(path: uri.path)
          dst.dirname = arg.to_s
          rename!(dst.path)
        end
        def filename=(arg)
          dst = ::Alt::URI.create(path: uri.path)
          dst.filename = arg.to_s
          rename!(dst.path)
        end
        def basename=(arg)
          dst = ::Alt::URI.create(path: uri.path)
          dst.ext = cx['ext'] if cx.has_key?('ext')
          dst.basename = arg.to_s
          rename!(dst.path)
        end
        def extname=(arg)
          dst = ::Alt::URI.create(path: uri.path)
          dst.ext = cx['ext'] if cx.has_key?('ext')
          dst.extname = arg.to_s
          rename!(dst.path)
          cx['ext'] = arg
        end

        def ss_type?
          case cx['ss_type']
          when nil
            'entries'
          when 'files', 'dirs', 'entries', 'skipfiles', 'skipdirs', 'skipentries'
            cx['ss_type'] 
          else
            nil
          end
        end

        require 'pathname'
        def realpath
          new_rio(fs.realpath(fspath))
        end
        def mountpoint?
          fs.mountpoint?(fspath)
        end
        def empty?() self.to_a.empty? end
        
      end

    end
  end
end

