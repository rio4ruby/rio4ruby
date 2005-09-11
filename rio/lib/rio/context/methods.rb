#--
# =============================================================================== 
# Copyright (c) 2005, Christopher Kleckner
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
# =============================================================================== 
#++
#
# To create the documentation for Rio run the command
#  rake rdoc
# from the distribution directory. Then point your browser at the 'doc/rdoc' directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Rio
#
# <b>Rio is pre-alpha software. 
# The documented interface and behavior is subject to change without notice.</b>


require 'rio/context/cxx.rb'
require 'rio/iomode'

require 'rio/context/stream'   
require 'rio/context/dir'   
require 'rio/context/skip'   
require 'rio/filter'   
require 'rio/context/closeoneof'   
require 'rio/context/gzip'   
require 'rio/context/copying'   

module RIO
  module Cx #:nodoc: all
    module SS
      STREAM_KEYS = %w[records lines rows bytes skiplines skiprows skiprecords nobytes]
      ENTRY_KEYS = %w[entries files dirs skipfiles skipdirs skipentries]
      KEYS = ENTRY_KEYS + STREAM_KEYS
    end
  end
end

module RIO
  module Cx
    module Methods
      def mode(arg)
#        p callstr('mode',arg)
        self.cx['mode'] = Mode::Str.new(arg)
        self 
      end
      def mode?()         
        self.cx['mode']
      end
      def mode_(arg=nil)  
        #p callstr('mode_',arg)  
        self.cx.set_('mode',Mode::Str.new(arg)) 
        self 
      end
      protected :mode_
    end
  end

  module Cx
    module Methods
      def closeoncopy(arg=true,&block) cxx('closeoncopy',arg,&block) end
      def nocloseoncopy(arg=false,&block) nocxx('closeoncopy',arg,&block) end
      def closeoncopy?() cxx?('closeoncopy') end 
      def closeoncopy_(arg=true)  cxx_('closeoncopy',arg) end
      protected :closeoncopy_
    end
  end

  module Cx
    module Methods
      def noautoclose(arg=false,&block)
        closeoncopy(arg).closeoneof(arg,&block)
      end
      def noautoclose_(arg=false)
        closeoncopy_(arg).closeoneof_(arg)
      end
      protected :noautoclose_
    end
  end

  module Cx
    module Methods
      def autorewind(arg=true,&block) cxx('autorewind',arg,&block) end
      def noautorewind(arg=false,&block) nocxx('autorewind',arg,&block) end
      def autorewind?() cxx?('autorewind') end 
      def autorewind_(arg=true)  cxx_('autorewind',arg) end
      protected :autorewind_
    end
  end

  module Cx
    module Methods
      def sync(arg=true,&block) 
        ioh.sync = arg unless ioh.nil?
        cxx('sync',arg,&block) 
      end
      def nosync(arg=false,&block) 
        ioh.sync = arg unless ioh.nil?
        nocxx('sync',arg,&block) 
      end
      def sync?() 
        setting = cxx?('sync')
        unless ioh.nil?
          actual = ioh.sync
          cxx_(actual) unless actual == setting
        end
        setting
      end 
      def sync_(arg=true)  
        cxx_('sync',arg) 
      end
      protected :sync_
    end
  end




  module Cx
    module Methods
      def all(arg=true,&block) cxx('all',arg,&block) end
      def noall(arg=false,&block) nocxx('all',arg,&block) end
      def all?() cxx?('all') end 
      def all_(arg=true)  cxx_('all',arg) end
      protected :all_
      
    end
  end
end
      
module RIO
  module Cx
    module Methods
      def nostreamenum(arg=true,&block) cxx('nostreamenum',arg,&block) end
      def nostreamenum?() cxx?('nostreamenum') end 
      def nostreamenum_(arg=true)  cxx_('nostreamenum',arg) end
      protected :nostreamenum_
      
    end
  end
end
module RIO
  module Cx
    module Methods
      def ext(arg=nil)
        arg ||= self.extname || ""
        self.cx['ext'] = arg
        self 
      end
      def noext()
        ext('')
        self 
      end
      def ext?() 
        self.cx.set_('ext',self.extname || "") if self.cx['ext'].nil?
        self.cx['ext'] 
      end
      def ext_(arg=nil)  
        arg ||= self.extname || ""
        self.cx.set_('ext',arg);
        self 
      end
      protected :ext_
    end
  end

  module Cx
    module Methods
      def a()  cx['outputmode'] = Mode::Str.new('a');  self end
      def a!() cx['outputmode'] = Mode::Str.new('a+'); self end
      def w()  cx['outputmode'] = Mode::Str.new('w');  self end
      def w!() cx['outputmode'] = Mode::Str.new('w+'); self end
      def r()  cx['inputmode']  = Mode::Str.new('r');  self end
      def r!() cx['inputmode']  = Mode::Str.new('r+'); self end
      def outputmode?() cxx?('outputmode') end
      def inputmode?()  cxx?('inputmode')  end
    end
  end
end
