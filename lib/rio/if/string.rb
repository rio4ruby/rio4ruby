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


module RIO
  class Rio
    # Returns the String associated with a Rio which references a StringIO object.
    # For any other type of Rio, is undefined.
    def string() target.string end
  end
end

module RIO
  module IF
    module String

      # Create a Rio referencing Rio#to_str + arg.to_str
      #
      #  rio('afile') + '-0.1'   #=> rio('afile-0.1')
      #
      def +(arg) target + arg end

      # Create a new Rio referencing the result of applying ::String#sub to the 
      # value returned by Rio#to_s. So:
      #
      #  ario.sub(re,string)
      # is equivelent to
      #  rio(ario.to_s.sub(re,string))
      #
      # See also #gsub, #+
      def sub(re,string) target.sub(re,string) end

      # Create a new Rio referencing the result of applying ::String#gsub to the 
      # value returned by Rio#to_s. So:
      #
      #  ario.gsub(re,string)
      # is equivelent to
      #  rio(ario.to_s.gsub(re,string))
      #
      # See also #sub #+
      def gsub(re,string) target.gsub(re,string) end
      
      
    end
  end
end
module RIO
  class Rio
    include RIO::IF::String
  end
end
