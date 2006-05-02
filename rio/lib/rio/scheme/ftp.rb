#--
# =============================================================================== 
# Copyright (c) 2005, 2006 Christopher Kleckner
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
#  ruby build_doc.rb
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


require 'net/ftp'
require 'open-uri'
require 'rio/ftp/conn'
require 'rio/ftp/fs'
require 'rio/rl/path'

module RIO
  module FTP #:nodoc: all
    RESET_STATE = 'FTP::State::Reset'
    #RESET_STATE = RIO::RL::PathBase::RESET_STATE
    
    require 'rio/rl/uri'

    class RL < RIO::RL::URIBase
      def self.splitrl(s) 
        sub,opq,whole = split_riorl(s)
        [whole] 
      end
      def openfs_
        RIO::FTP::FS.new(@uri)
      end
      def open(*args)
        RIO::FTP::Conn.new(@uri)
      end
    end
    module Stream
      class RL < RIO::RL::URIBase
        def self.splitrl(s) 
          sub,opq,whole = split_riorl(s)
          [whole] 
        end
        def open(*args)
          RIO::IOH::Stream.new(@uri.open)
        end
      end
    end
  end
end
