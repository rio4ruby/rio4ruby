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


require 'net/ftp'
require 'open-uri'
require 'rio/ftp/fs'
require 'rio/rrl/path'
require 'rio/ftp/dir'
require 'rio/ftp/ftpfile'

module RIO
  module FTP #:nodoc: all
    RESET_STATE = RIO::RRL::PathBase::RESET_STATE
    
    require 'rio/rrl/withpath'

    class RRL < RIO::RRL::URIBase
      def _sup_args(arg0,*args)
        if arg0 == 'ftp:'
          hn = args.shift || 'localhost'
          us = args.shift 
          pw = args.shift
          pt = args.shift || ''
          ph = args.shift || '/'
          tc = args.shift || ''
          u = URI::FTP.new2(us,pw,hn,pt,ph,tc)
          return [u]
        else
          return [arg0] + args
        end
      end
      def typecode() uri.typecode end
      def typecode=(val) uri.typecode = val end

      def openfs_
        #p callstr('openfs_',self.uri)
        RIO::FTP::FS.create(self.uri)
      end
      def open(*args)
        IOH::Dir.new(RIO::FTP::Dir::Stream.new(self.uri))
      end
      def file_rl() 
        RIO::FTP::Stream::RRL.new(self.uri) 
      end
      def dir_rl() 
        self 
      end
    end
    module Stream
      class RRL < RIO::RRL::URIBase
        def self.splitrl(s) 
          sub,opq,whole = split_riorl(s)
          [whole] 
        end
        def openfs_
          RIO::FTP::FS.create(@uri)
        end
        def open(m)
          case
          when m.primarily_write?
            RIO::IOH::Stream.new(RIO::FTP::FTPFile.new(fs.remote_path(@uri.to_s),fs.conn))
          else
            u = URI.parse(@uri.to_s)
            hndl = u.open
            RIO::IOH::Stream.new(hndl)
          end
        end
        def file_rl() 
          self
        end
      end
    end
  end
end
