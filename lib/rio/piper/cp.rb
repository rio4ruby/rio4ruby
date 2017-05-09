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
        def last_rio(r)
          r = r.rl.query[-1] while r.scheme == 'cmdpipe'
          r
        end
        def has_output_dest?(nrio)
          !%w[cmdio cmdpipe].include?(last_rio(nrio).scheme)
        end

        def |(arg)
          ario = ensure_cmd_rio(arg)
          nrio = new_rio(:cmdpipe,self.clone_rio,ario)
          
          if has_output_dest?(nrio) 
            nrio.run 
          else
            nrio
          end

        end
      end
    end
  end
end

__END__
