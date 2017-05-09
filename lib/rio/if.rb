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
  class Rio
    require 'rio/if/csv'
    include RIO::IF::CSV
    require 'rio/if/yaml'
    include RIO::IF::YAML
  end
end

require 'rio/if/internal'
#require 'rio/if/basic'

module RIO
  module IF
    #autoload :Grande,           'rio/if/grande' 
    require 'rio/if/grande' 

    #autoload :GrandeEntry,      'rio/if/grande_entry' 
    require 'rio/if/grande_entry' 
    #autoload :GrandeStream,     'rio/if/grande_stream' 
    require 'rio/if/grande_stream' 
    #autoload :Test,             'rio/if/test'
    require 'rio/if/test'

    require 'rio/if/path'
    require 'rio/if/fileordir'
    require 'rio/if/file'
    require 'rio/if/dir'
    require 'rio/if/rubyio'
    require 'rio/if/temp'
    require 'rio/if/string'
  end

end
