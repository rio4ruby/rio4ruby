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


module RIO
  module Piper #:nodoc: all
    module Cp
      module Util

        protected

        def process_pipe_arg0_(npiper)
          erio = npiper.rios[-1]
          case erio.scheme
          when 'cmdio'
            new_rio(:cmdpipe,npiper)
          when 'cmdpipe'
            if erio.has_output_dest?
              npiper.run
              erio
            else
              new_rio(:cmdpipe,npiper)
            end
          else
            npiper.run
            erio
          end
        end

        def process_pipe_arg_(ario)
          case ario.scheme
          when 'cmdio'
            new_rio(:cmdpipe,ario)
          when 'cmdpipe'
            new_rio(:cmdpipe,ario)
          else
            new_rio(:cmdpipe,ario)
          end
        end

      end
      module Input
        include Util
        #def last_rio(r)
        #  r.scheme == 'cmdpipe' ? last_rio(r.rl.query[-1]) : r
        #end
        def last_rio(r)
          r = r.rl.query[-1] while r.scheme == 'cmdpipe'
          r
        end
        #define_method(:last_rio) do |r|
        #  if r.scheme == 'cmdpipe'
        #    r = r.rl.query[-1]
        #    redo
        #  else
        #    r
        #  end
        #end
        def has_output_dest?(nrio)
          !%w[cmdio cmdpipe].include?(last_rio(nrio).scheme)
        end

        def |(arg)
          #p 'HERE 3'
          ario = ensure_cmd_rio(arg)
          nrio = new_rio(:cmdpipe,self.clone_rio,ario)
          
          if has_output_dest?(nrio) 
            #p 'nrio.run'
            nrio.run 
          else
            #p 'nrio'
            nrio
          end

        end
      end
    end
  end
end

__END__
