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
  module Ops
    module Path
      module Create
        def join(*args) 
          rtn_rio {
            uri.clone.join(*args)
          }
        end
        def join!(*args)
          rtn_reset {
            uri.join(*args)
          }
        end
        def /(arg)
          join(arg)
        end

        def getwd(*args,&block) 
          new_rio(fs.getwd,*args,&block) 
        end
        def cwd(*args,&block) 
          new_rio(fs.cwd,*args,&block) 
        end
        
        def rootpath(*args,&block) 
          new_rio(fs.root(),*args,&block) 
        end
        alias :root :rootpath
        def cleanpath(*args)
          new_rio(fs.cleanpath(fspath,*args))
        end
      end
    end
  end
end
