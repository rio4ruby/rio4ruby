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


# module RIO
#   module Impl
#     module U
#       def self.readlink(s,*args) ::File.readlink(s,*args) end
#       def self.lstat(s,*args) ::File.lstat(s,*args) end
#     end
#   end
# end
module RIO
  module Ops
    module Symlink
      module ExistOrNot
        def readlink(*args) new_rio(fs.readlink(self.to_s,*args)) end
        def lstat(*args) fs.lstat(self.to_s,*args) end

      end
      module Existing
        include ExistOrNot
        def delete(*args)
          rtn_reset {
            fs.delete(self.to_s)
          }
        end
        def unlink(*args)
          delete(*args)
        end
        def delete!(*args)
          delete(*args)
        end
      end
      module NonExisting
        include ExistOrNot
        def mkdir()
          rtn_reset {
            self.readlink.mkdir
          }
        end
        def mkpath()
          rtn_reset {
            self.readlink.mkpath
          }
        end
      end
    end
  end
end
