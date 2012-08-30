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

require 'rio/fs/base'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'rio/scheme/path'
require 'rio/ext/zipfile/wrap'

module RIO
  module ZipFile
    module RootDir
      class FS
        attr_reader :dir
        def initialize(zipfile)
          @zipfile = zipfile
          @dir = @zipfile.dir
          @file = @zipfile.file
          @test = @zipfile.file
          #p "InFile: #{@file.class}"
        end
        def commit(&block)
          yield if block_given?
          @zipfile.commit
        end
        include RIO::FS::Str
        include RIO::FS::Dir
        include RIO::FS::Test
        def mkdir(*args)
          commit{super}
        end
        def rmdir(*args)
          commit{@dir.rmdir(*args)}
        end
      end
    end
    module InFile
      class FS
        attr_reader :file,:dir
        def initialize(zipfile)
          @zipfile = zipfile
          @file = RIO::ZipFile::Wrap::File.new(@zipfile.file)
          @dir = RIO::ZipFile::Wrap::Dir.new(@zipfile.dir)
          @test = @file
          #p "InFile: #{@file.class}"
        end
        include RIO::FS::File
        include RIO::FS::Dir
        include RIO::FS::Test
        include RIO::FS::Str
      end
    end
  end
end

__END__

      
      class CentralDir < RIO::FS::Native
        def initialize(zipfilepath)
          @zipfilepath = zipfilepath
          @zipfile = Zip::ZipFile.new(@zipfilepath)
          super
        end
        def mkdir(path)
          @zipfile.mkdir(path)
        end
        def rmdir(path)
          @zipfile.remove(path)
        end
        def file()
          self
        end
        def open(zipfilepath)
          @zipfilepath = zipfilepath
          @zipfile = Zip::ZipFile.new(@zipfilepath)
          RIO::ZipFile::CentralDir.new(@zipfile)
        end

      end

    end
  end
end
