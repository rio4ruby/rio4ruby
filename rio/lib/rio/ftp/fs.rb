#--
# =============================================================================== 
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
# =============================================================================== 
#++
#
# To create the documentation for Rio run the command
#  ruby build_doc.rb
# from the distribution directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#

require 'net/ftp'
require 'rio/alturi'
require 'rio/fs/native'
require 'rio/ftp/conncache'

module RIO
  module FTP
    class FS 
      attr_reader :uri
      def initialize(uri)
        @uri = uri.clone
        @file = ::File
        @conn = nil
      end
      def self.create(*args)
        new(*args)
      end
      def remote_root
        conn.remote_root.sub(%r{/*$},'/')
      end
      def remote_wd
        conn.pwd.sub(%r{/*$},'/')
      end
      def conn
        @conn ||= ConnCache.instance.connect(@uri)
      end



      def root()
        uri = @uri.clone
        uri[:path] = '/'
        uri.to_s
      end
      include RIO::FS::Str

      
      def pwd() conn.pwd end
      def getwd()
        #p "GETWD self.pwd=#{self.pwd}"
        self.pwd
      end
      def cwd()
        remote_wd = self.pwd.sub(%r{/*$},'/')
        remote_rel = remote_wd.sub(/^#{self.remote_root}/,'')
        wduri = uri.clone
        wduri.path = remote_rel
        wduri.to_s
      end
      def remote_path(url)
        #p "remote_path: url=#{url.inspect}"
        uri = Alt::URI.parse(url)
        path = uri.path
        wd = self.pwd
        #p "remote_path remote_root=#{self.remote_root} path=#{path} wd=#{wd}"
        rpth = if path.start_with?('/') 
                 path 
               else
                 self.remote_wd + path
               end
        rpth
      end
      def chdir(url,&block)
        #p "ftp::fs chdir url=#{url}"
        if block_given?
          wd = conn.pwd
          conn.chdir(remote_path(url))
          begin
            rtn = yield remote_wd
          ensure
            conn.chdir(wd)
          end
          return rtn
        else
          conn.chdir(remote_path(url))
        end
      end
      def mkdir(url)
        conn.mkdir(remote_path(url))
      end
      def mv(src_url,dst_url)
        conn.rename(remote_path(src_url),remote_path(dst_url))
      end
      def size(url)
        conn.size(remote_path(url))
      end
      def zero?(url)
        size(url) == 0
      end
      def mtime(url)
        conn.mtime(remote_path(url))
      end
      def rmdir(url)
        conn.rmdir(remote_path(url))
      end
      def rm(url)
        conn.delete(remote_path(url))
      end
      def put(localfile,remote_file = ::File.basename(localfile))
        conn.put(localfile,remote_path(remote_file))
      end

      def get_ftype(url)
        #p "get_ftype(#{url})"
        pth = remote_path(url)
        #p "URL=#{url},PTH=#{pth}"
        ftype = nil
        begin
          conn.mdtm(pth)
          ftype = :file
        rescue Net::FTPPermError
          wd = conn.pwd
          begin
            conn.chdir(pth)
            ftype = :dir
          rescue Net::FTPPermError
            ftype = :nada
          ensure
            conn.chdir(wd)
          end
        end
        ftype
      end
      def file?(url)
        get_ftype(url) == :file
      end
      def directory?(url)
        get_ftype(url) == :dir
      end
      def exist?(url)
        get_ftype(url) != :nada
      end
      def symlink?(url)
        false
      end
      def mkpath(url)
        #p "mkpath: #{url.inspect}"
        pathparts = url.split('/')
        pathparts.shift if pathparts[0] == ""
        pathparts[0] = '/' + pathparts[0] if url.start_with?('/')
        pth = ""
        pathparts.each do |part|
          pth += pth.empty? ? part : '/' + part
          mkdir(pth) unless exist?(pth)
        end
      end
      def rmtree(url)
        _rment(url)
      end

      private

      def _rment(url)
        #p "_rment(#{url})"
        ftype = get_ftype(url)
        case ftype
        when :file
          rm(url)
        when :dir
          nlst = conn.nlst(url)
          nlst.each do |ent|
            _rment(ent)
          end
          rmdir(url)
        end
      end
    end
  end
end
