#--
# ===========================================================================
# Copyright (c) 2005-2017 Christopher Kleckner
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

require 'uri'
require 'rio/uri/file'
require 'rio/ext/zipfile/fs'

module RIO
  module ZipFile #:nodoc: all
    module RootDir
      RESET_STATE = 'ZipFile::State::Reset'
      
      require 'rio/rl/base'
      class RL < RIO::RL::Base 
        RIOSCHEME = 'zipfile'
        RIOPATH = RIO::RL::CHMAP.invert[RIOSCHEME].to_s.freeze
        attr_reader :zipfilepath,:infilepath
        def initialize(zipfilepath,infilepath=nil)
          @zipfilepath = zipfilepath
          @uri = URI(@zipfilepath)
          if infilepath
            @infilepath = infilepath
            @uri.query = @infilepath
          end
          @zipfile = ::Zip::ZipFile.new(@zipfilepath,::Zip::ZipFile::CREATE)
          super()
        end
        def file_rl
          RIO::File::RL.new(infilepath,{:fs => RIO::ZipFile::InFile::FS.new(@zipfile)})
        end
        def openfs_()
          RIO::ZipFile::RootDir::FS.new(@zipfile)
        end
        def open()
          IOH::Dir.new(ZipFile::Wrap::Stream::Root.new(@zipfile))
        end
        def close()
        end
        def path()
          @infilepath
        end
        def fspath()
          @infilepath
        end
        def base(*args) 
          '' 
        end
        def path_no_slash() self.path.to_s.sub(/\/$/,'') end
        #def path() nil end
        def scheme() self.class.const_get(:RIOSCHEME) end
        def opaque()
          @uri.to_s
        end
        include RIO::RL::PathMethods
        def urlpath() 
          return '' unless fspath
          RIO::RL.fs2url(fspath) 
        end
        def urlpath=(arg) @infilepath = RIO::RL.url2fs(arg) end

        # USAGE EXAMPLES
        # zroot = rio('f.zip').zipfile
        #
        # rio(zroot,'tdir').mkdir
        # rio(zroot,'tdir').mkdir
        # rio(zroot).each {}
        # rio(:zipfile,'t.zip','tdir').mkdir
        # rio('zipfile:t.zip','tdir').mkdir
        # rio('zipfile:t.zip?tdir').mkdir
        # rio(?z,'t.zip?tdir').mkdir
        # rio(?z,'t.zip','tdir').mkdir
        # rio('zipfile:file:///tmp/t.zip?tdir').mkdir
        SPLIT_RE = %r|(.+)(?:\?(.+))?$|.freeze
        def self.splitrl(s)
          sub,opq,whole = split_riorl(s)
          if opq.nil? or opq.empty?
            []
          elsif bm = SPLIT_RE.match(opq)
            zpath = bm[1] unless bm[1].nil? or bm[1].empty?
            ipath = bm[2] unless bm[2].nil? or bm[2].empty?
            [zpath,ipath]
          else
            []
          end
        end
      end
    end
  end
end


__END__
