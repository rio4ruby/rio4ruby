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


require 'rio/rl/base'
require 'rio/exception/notimplemented'
require 'rio/rl/builder'

module RIO
  module RL
    module PathUtil
    end
  end
end
      # 

module RIO
  module RL
    class WithPath < RIO::RL::Base
      include RIO::RL::PathUtil
      include RIO::Error::NotImplemented

      # returns an appriate FS object for the scheme
      def openfs_() nodef() end

      # returns the path portion of a URL. All spaces would be %20
      # returns a String
      def urlpath() nodef() end
      def urlpath=(arg) nodef(arg) end

      # For RLs that are on the file system this is fspath()
      # For RLs that are remote (http,ftp) this is urlpath()
      # For RLs that have no path this is nil
      # returns a String
      def path() nodef{} end
      def path=(arg) nodef(arg) end

      # returns A URI object representation of the RL if one exists
      # otherwise it returns nil
      # returns a URI
      def uri() nodef() end

      # when the URL is legal it is the URI scheme
      # otherwise it is one of Rio's schemes
      # returns a String
      def scheme() nodef() end

      # returns the host portion of the URI if their is one
      # otherwise it returns nil
      # returns a String
      def host() nodef() end
      def host=(arg) nodef(arg) end

      # returns the portion of the URL starting after the colon
      # following the scheme, and ending before the query portion
      # of the URL
      # returns a String
      def opaque() nodef() end

      # returns the portion of the path that when prepended to the 
      # path would make it usable.
      # For paths on the file system this would be '/'
      # For http and ftp paths it would be http://host/
      # For zipfile paths it would be ''
      # For windows paths with a drive it would be 'C:/'
      # For windows UNC paths it would be '//host/'
      # returns a String
      def pathroot() nodef() end


      # returns the base of a path. 
      # merging the value returned with this yields the absolute path
      def base(thebase=nil) nodef(thebase) end

    end
  end
end

module RIO
  module RL
    class WithPath < RIO::RL::Base
      # returns the path as the file system sees it. Spaces are spaces and not
      # %20 etc. This is the path that would be passed to the fs object.
      # For windows RLs this includes the '//host' part and the 'C:' part
      # returns a String
      def fspath()
        uri.netpath
      end

      def fspath=(fpth)
        uri.netpath = fpth
      end
      
      def is_root?(upth)
        upth =~ %r%^(/?[a-zA-Z]:)?/% or upth =~ %r%^//(#{HOST})%
      end

      # The value of urlpath() with any trailing slash removed
      # returns a String
      def path_no_slash() 
        path.sub(%r{/*$},'')
      end
      # The value of fspath() with any trailing slash removed
      # returns a String
      def fspath_no_slash() 
        fspath.sub(%r{/*$},'')
      end
      def pathdepth()
        pth = self.path_no_slash
        pth.count('/')
      end

      def _uri(arg)
        arg.kind_of?(::Alt::URI) ? arg.clone : ::Alt::URI.parse(arg.to_s)
      end
      # returns the absolute path. combines the urlpath with the
      # argument, or the value returned by base() to create an
      # absolute path.
      # returns a RL
      def abs(thebase=nil) 
        thebase ||= self.base
        base_uri = _uri(thebase)
        path_uri = self.uri.clone
        if path_uri.scheme == 'file' and base_uri.scheme != 'file'
          abs_uri = path_uri.abs(base_uri)
        else
          abs_uri = path_uri.abs(base_uri)
        end
        _build(abs_uri,{:fs => self.fs})
      end


      # returns an array of parts of a RL.
      # 'a/b/c' => ['a','b','c']
      # For absolute paths the first component is the pathroot
      # '/topdir/dir/file' => ['/','topdir','dir','file']
      # 'http://host/dir/file' => ['http://host/','dir','file']
      # '//host/a/b' => ['file://host/','a','b']
      # each element of the array is an RL whose base is
      # set such that the correct absolute path would be returned
      # returns an array of RLs
      def _parts()
        pr = self.pathroot
        ur = self.urlroot.sub(/#{pr}$/,'')
        up = self.urlpath.sub(/^#{pr}/,'')

        [ur,pr,up]
      end
      def split()
        if absolute?
          parts = self._parts
          sparts = []
          sparts << parts[0] + parts[1]
          sparts += parts[2].split('/')
        else
          sparts = self.urlpath.split('/')
        end
        rlparts = sparts.map { |str| self.class.new(str) }
        (1...sparts.length).each { |i|
          base_str = rlparts[i-1].abs.url
          base_str += '/' unless base_str[-1] == ?/
          rlparts[i].base = base_str
        }
        rlparts

      end

      # changes this RLs path so that it consists of this RL's path
      # combined with those of its arguments.
      def join(*args)
        return self if args.empty?
        sa = args.map { |arg| arg.to_s }
        join_(sa)
      end
      def join_(sa)
        sa.unshift(self.urlpath) unless self.urlpath.empty?
        self.urlpath = sa.join('/').squeeze('/')
        self
      end
      protected :join_

      # returns the directory portion of the path
      # like File#dirname
      # returns a RL
      def dirname() 
        RIO::RL::Builder.build(uri.dirname)
      end
        
      # returns the tail portion of the path minus the extension
      # returns a RL
      def basename(ext)
        #p callstr('basename',ext)
        base_rl = self.abs
        base_rl.fspath = fs.dirname(base_rl.fspath_no_slash)
        path_str = fs.basename(self.path,ext)
        _build(path_str,{:base => base_rl.uri, :fs => self.fs})
      end
      def build_arg0_(path_str)
        path_str
      end

      # returns the tail portion of the path
      # returns a RL
      def filename() 
        basename('')
      end


      # calls URI#merge
      # returns a RL
      def merge(other) _build(self.uri.merge(other.uri)) end

      # calls URI#route_from
      # returns a RL
      def route_from(other) _build(self.uri.route_from(other.uri),{:base => other.uri}) end

      # calls URI#route_to
      # returns a RL
      def route_to(other) _build(self.uri.route_to(other.uri),{:base => self.uri}) end

      def _build(*args) RIO::RL::Builder.build(*args) end

      def uri_from_string_(str)
        ::Alt::URI.parse(str)
      end
    end
  end
end


