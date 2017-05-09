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

require 'rio/alturi'

module RIO
  class CxURI
    def initialize(r)
      case r
      when ::RIO::Rio
        u = r.uri
        @parts = ::Alt::URI::Gen::URIParts.parse(u.to_s)
        self.fragment = r.cx
      else
        @parts = ::Alt::URI::Gen::URIParts.parse(r.to_s)
      end
    end
    def to_rio
      nparts = @parts.clone
      cx = self.fragment
      nparts.fragment = nil
      nrio = Rio.rio(nparts.to_s)
      nrio.cx = cx
      nrio
    end
    def fragment=(arg)
      @parts.fragment = arg.nil? ? nil : YAML.dump(arg)
    end
    def fragment
      YAML.load(@parts.fragment) unless @parts.fragment.nil?
    end

    extend RIO::Fwd

    fwd :@parts,
        :authority,
        :scheme,
        :path,
        :query,
        :userinfo,
        :host,
        :port

    def to_s
      @parts.uri
    end


  end
end
