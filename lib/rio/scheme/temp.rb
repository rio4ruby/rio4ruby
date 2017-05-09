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

require 'tmpdir'
require 'rio/rrl/base'

module RIO
  module Temp #:nodoc: all
    RESET_STATE = 'Temp::Reset'

    class RRL < ::RIO::RRL::Base 
      RIOSCHEME = 'temp'
      RIOPATH = RIO::RRL::CHMAP.invert[RIOSCHEME].to_s.freeze
      DFLT_PREFIX = 'rio'
      DFLT_TMPDIR = ::Dir::tmpdir
      def initialize(u,file_prefix=DFLT_PREFIX,temp_dir=DFLT_TMPDIR)
        alturi = case u
                 when ::Alt::URI::Base then u
                 else ::Alt::URI.parse(u.to_s)
                 end
        prefix = alturi.query || file_prefix.to_s
        tmpdir = (alturi.path.nil? || alturi.path.empty?) ? 
          temp_dir.to_s : alturi.path
        super(alturi)
        self.path = tmpdir
        self.query = prefix
      end

      extend RIO::Fwd
      fwd :uri, :path, :query
      fwd_reader :uri, :scheme

      alias :prefix :query
      alias :tmpdir :path

    end
    module Dir
      require 'rio/rrl/path'
      RESET_STATE = RIO::RRL::PathBase::RESET_STATE
      require 'tmpdir'
      class RRL < RIO::RRL::PathBase 
        RIOSCHEME = 'tempdir'
        DFLT_PREFIX = Temp::RRL::DFLT_PREFIX
        DFLT_TMPDIR = Temp::RRL::DFLT_TMPDIR

        def initialize(u,file_prefix=DFLT_PREFIX,temp_dir=DFLT_TMPDIR)
          require 'rio/tempdir'
          alturi = case u
                   when ::Alt::URI::Base then u
                   else ::Alt::URI.parse(u.to_s)
                   end
          prefix = alturi.query || file_prefix.to_s
          tmpdir = (alturi.path.nil? || alturi.path.empty?) ? 
             temp_dir.to_s : alturi.path
          td = ::Tempdir.new( prefix, tmpdir)
          td = "file:///" + td.to_s if td.to_s =~ /^[a-zA-Z]:/
          super(td.to_s)
        end
        extend RIO::Fwd
        fwd :uri, :path, :query
        alias :prefix :query
        alias :tmpdir :path

        def dir_rl() 
          RIO::Dir::RRL.new(self.uri, {:fs => self.fs})
        end
      end
    end
    module File
      require 'rio/rrl/path'
      RESET_STATE = 'Temp::Stream::Open'
      class RRL < RIO::RRL::PathBase 
        RIOSCHEME = 'tempfile'
        DFLT_PREFIX = Temp::RRL::DFLT_PREFIX
        DFLT_TMPDIR = Temp::RRL::DFLT_TMPDIR

        def initialize(u,file_prefix=DFLT_PREFIX,temp_dir=DFLT_TMPDIR)
          require 'tempfile'
          # FIXME: Temporary fix for jruby 1.4 - make tmpdir absolute
          #tmpdir_rio = rio(@tmpdir).abs
          alturi = case u
                   when ::Alt::URI::Base then u
                   else ::Alt::URI.parse(u.to_s)
                   end
          prefix = alturi.query || file_prefix.to_s
          tmpdir = (alturi.path.nil? || alturi.path.empty?) ? 
             temp_dir.to_s : alturi.path

          @tf = ::Tempfile.new( prefix, tmpdir)

          # FIXME: Temporary fix for jruby 1.4 - fix slashes
          pth =  @tf.path
          pth.gsub!("\\","/")
          pth = "file:///" + pth if pth =~ /^[a-zA-Z]:/

          super(::Alt::URI.parse(pth))
        end
        extend RIO::Fwd
        fwd :uri, :path, :query
        def file_rl() 
          RIO::File::RRL.new(self.uri,{:fs => self.fs})
        end
        def open(mode='ignored')
          @tf
        end
        def close 
          super
          @tf = nil
        end
      end
    end
    require 'rio/state'
    class Reset < State::Base
      def initialize(*args)
        super
        @tempobj = nil
      end
      def self.default_cx
        Cx::Vars.new( { 'closeoneof' => false, 'closeoncopy' => false } )
      end

      def check?() true end
      def mkdir(prefix=rl.prefix,tmpdir=rl.tmpdir)
        self.rl = RIO::Temp::Dir::RRL.new("",prefix, tmpdir)
        become 'Dir::Existing'
      end
      def chdir(&block)
        self.mkdir.chdir(&block)
      end
      def file(prefix=rl.prefix,tmpdir=rl.tmpdir)
        # p "scheme/temp.rb file(): prefix="+prefix+" tmpdir="+tmpdir
        self.rl = RIO::Temp::File::RRL.new("",prefix, tmpdir)
        become 'Temp::Stream::Open'
      end
      def scheme() rl.scheme() end
      def host() rl.host() end
      def opaque() rl.opaque() end
      def to_s() rl.url() end
      def exist?() false end
      def file?() false end
      def dir?() false end
      def open?() false end
      def closed?() true end
      def when_missing(sym,*args)
        if @tempobj.nil?
          file()
        else
          gofigure(sym,*args)
        end
      end
    end
    require 'rio/stream/open'
    module Stream
      class Open < RIO::Stream::Open
        def iostate(sym)
          mode_('w+').open_.inout()
        end
      end
    end
  end
end
