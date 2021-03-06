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

require 'zip/zip'
require 'zip/zipfilesystem'
require 'delegate'

module RIO
  module ZipFile
    module Wrap
      module Stream
        class Input < DelegateClass(::Zip::ZipInputStream)
          def initialize(zipstream)
            @closed = false
            super
          end
          def close()
            super
            @closed = true
          end
          def closed?() @closed end
        end
        class Output < DelegateClass(::Zip::ZipOutputStream)
          def initialize(zipstream)
            @closed = false
            @zipstream = zipstream
            super
          end
          def close()
            super
            @closed = true
          end
        end
        class Dir < DelegateClass(::Zip::ZipFileSystem::ZipFsDirIterator)
        end
        class Root 
          def initialize(zipfile)
            @zipfile = zipfile
            @infs = RIO::ZipFile::InFile::FS.new(@zipfile)
            @topents = get_topents_
            @entidx = 0
          end
          def get_topents_
            topents = {}
            @zipfile.entries.map{ |ent|
              top = ent.to_s.match(%r|^(/?[^/]+(/)?)|)[1]
              topents[top] = 1 unless topents.has_key?(top)
            }
            topents.keys.map{ |v| rio(RIO::Path::RL.new(v.to_s,{:fs => @infs})) }
          end
          def read
            return nil if @entidx >= @topents.size
            @entidx += 1
            @topents[@entidx-1]
          end
          def each(&block)
            get_topents_.each { |ent|
              yield ent
            }
          end
          def close
            @zipfile.commit if @zipfile.commit_required?
          end
        end
      end
      class File < DelegateClass(::Zip::ZipFileSystem::ZipFsFile)
        def open(filename, openMode, *args)
          zipstream = super
          
          case openMode
          when 'r' then Stream::Input.new(super)
          when 'w' then Stream::Output.new(super)
          end
        end
      end
      class Dir < DelegateClass(::Zip::ZipFileSystem::ZipFsDir)
        def open(*args)
          super
        end
      end
      class RootDir < DelegateClass(::Zip::ZipFile)
        
      end
    end
  end
end
__END__
