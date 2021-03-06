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

#

require 'rio'

module RIO
  def prompt(str="")
    rio(?-).strip.print(str).gets
  end
  def promptd(str="",default=nil)
    dstr = default ? "[#{default}]: " : ": "
    pstr = str + dstr
    ans = prompt(pstr)
    ans.empty? ? default : ans
  end
  def promptr(str="",default=nil)
    ans = promptd(str,default)
    rio(ans)
  end
  module_function :prompt,:promptd,:promptr
end

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__

puts
puts("Run the tests that came with the distribution")
puts("From the distribution directory use 'test/runtests.rb'")
puts
