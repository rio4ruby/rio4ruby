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
require 'rio/uriref'
require 'rio/fwd'
require 'rio/exception/notimplemented'
require 'rio/fs'

module RIO
  module RRL
    module PathUtil
    end
  end
end
      # 

module RIO
  module RRL
    class WithPath < RIO::RRL::Base
      include RIO::RRL::PathUtil
      include RIO::Error::NotImplemented

      # returns an appriate FS object for the scheme
      def openfs_() nodef() end

      # For RLs that are on the file system this is fspath()
      # For RLs that are remote (http,ftp) this is urlpath()
      # For RLs that have no path this is nil
      # returns a String
      def path() nodef{} end
      def path=(arg) nodef(arg) end

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
  module RRL
    class WithPath < RIO::RRL::Base
      extend Fwd

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

      fwd :uri,:netpath, :fspath
      fwd_readers :uri, :abs, :rel, :route_to, :route_from
      fwd_readers :uri, :join, :rel, :route_to, :route_from
      fwd :uri, :dirname, :basename, :extname, :filename
      fwd :uri, :scheme, :authority, :path, :query, :fragment
      fwd :uri, :host, :port, :userinfo, :netpath, :user, :password

      def absolute?
        uri.absolute?
      end
      def base
        uri.base
      end

      def base=(other)
        uri.base = other
      end

      def split()
        u = self.uri.normalize
        scheme = u.scheme == 'file' ? nil : u.scheme
        uauth = u.authority
        authpart = uauth unless (scheme.nil? and (uauth.nil? || uauth.empty? || uauth == 'localhost'))
        if u.path.start_with?("/")
          rootpathpart = "/"
          pathpart = u.path[1..-1]
        else
          pathpart = u.path
        end
        pparts = pathpart.split("/")
        
        rootpath = ::Alt::URI.create(:scheme => scheme, :authority => authpart, :path => rootpathpart).to_s
        sparts = [rootpath,pparts].flatten
        basepart = if rootpath.empty?
                     ::Alt::URI.create(:scheme => 'file', :authority => "", :path => ::Dir.getwd + "/").to_s
                   else
                     rootpath
                   end

        bparts = [basepart]
        bparts << basepart.clone

        (1...sparts.length).each do |n|
          basepart += sparts[n] + "/"
          bparts << basepart.clone
        end

        if sparts[0].empty?
          sparts.shift
          bparts.shift
        end
        
        [sparts,bparts]

      end

    end
  end
end


module RIO
  module RRL
    class URIBase < WithPath

      def initialize(u,*args)
        # u should be a ::URI or something that can be parsed to one
        #p callstr('initialize',u,*args)
        args,opts = _get_opts_from_args(args)
        uriref = case u
                 when ::Alt::URI::Base
                   _uriref_from_alturi(u,opts,*args)
                 when ::RIO::URIRef
                   if opts[:base]
                     _uriref_from_alturi(u.ref,opts,*args)
                   else
                     rtn = u.clone.join(*args)
                     rtn
                   end
                 else
                   _uriref_from_alturi(::Alt::URI.parse(u.to_s,opts),opts,*args)
                 end

        super(uriref,opts[:fs])
        opts[:fs] ||= openfs_

        self.uri.parts.encoding ||= opts[:fs].encoding
      end

      private

      def _uriref_from_alturi(alturi,opts,*args)
        alturi.join(*args)
        ::RIO::URIRef.build(alturi,opts)
      end
      def _get_opts_from_args(args)
        opts = {}
        if !args.empty? and args[-1].kind_of?(::Hash) 
          opts = args.pop
        end
        [args,opts]
      end

      public

      def self.parse(*a)
        u = a.shift.sub(/^rio:/,'')
        new(u,*a)
      end
      def initialize_copy(other)
        super
      end
      def openfs_()
        #p callstr('openfs_')
        self.fs || RIO::FS::LOCAL
      end
    end
  end
end
