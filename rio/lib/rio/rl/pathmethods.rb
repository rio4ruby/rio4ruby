#--
# ===========================================================================
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
# =========================================================================== 
#++
#
#
# ==== Rio - Ruby I/O Facilitator
#
# Rio is a facade for most of the standard ruby classes that deal with
# I/O; providing a simple, intuitive, succinct interface to the
# functionality provided by IO, File, Dir, Pathname, FileUtils,
# Tempfile, StringIO, OpenURI and others. Rio also provides an
# application level interface which allows many common I/O idioms to be
# expressed succinctly.
#
# ===== Suggested Reading
#
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#
# Project::       http://rubyforge.org/projects/rio/
# Documentation:: http://rio4ruby.com/
# Bugs::          http://rubyforge.org/tracker/?group_id=821
# Blog::          http://rio4ruby.blogspot.com/
# Email::         rio4ruby@rubyforge.org
#


require 'rio/rl/uri'
module RIO
  module RL
    module PathMethods
      def urlroot()
        return nil unless absolute?
        cp = self.clone
        cp.urlpath = self.pathroot
        cp.url
      end
      def pathdepth()
        pth = self.path_no_slash
        (pth == '/' ? 0 : pth.count('/'))
      end
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
        require 'rio/to_rio'
        rlparts = sparts.map { |str| self.class.new(str) }
        (1...sparts.length).each { |i|
          rlparts[i].base = rlparts[i-1].abs.url + '/'
        }
        rlparts
      end

      def join(*args)
        return self if args.empty?
        sa = args.map { |arg| ::URI.escape(arg.to_s,ESCAPE) }
        sa.unshift(self.urlpath) unless self.urlpath.empty?
        self.urlpath = sa.join('/').squeeze('/')
        self
      end

      def parse_url(str)
        ::URI.parse(::URI.escape(str,ESCAPE))
      end

      def route_from(other)
        self.class.new(uri.route_from(other.uri),{:base => other.url})
      end
      def route_to(other)
        self.class.new(uri.route_to(other.uri),{:base => self.url})
      end
      def merge(other)
        self.class.new(uri.merge(other.uri))
      end
      def calc_abs_uri_(path_str,base_str)
        #p path_str,base_str
        path = URI(path_str)
        return path unless base_str
        if path_str[0,1] != '/' and base_str[0,1] == '/'
          abs_str = [base_str,path_str].join('/').squeeze('/')
          return URI(abs_str)
        end
        base = URI(base_str)
        abs = base.merge(path)
        return abs
      end

      def dirname()
        ::File.dirname(self.path_no_slash)
      end


    end
  end
end
