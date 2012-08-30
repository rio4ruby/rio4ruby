#--
# ===========================================================================
# Copyright (c) 2005-2012 Christopher Kleckner
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


require 'singleton'
require 'rio/handle'
require 'rio/rrl/builder'

# module RIO
#   autoload :Path, 'rio/rrl/path'
#   module Path
#     autoload :Str,'rio/path'
#     autoload :Reset , 'rio/path/reset'
#     autoload :Empty , 'rio/path'
#     autoload :NonExisting , 'rio/path'
#     module Stream
#       autoload :Open , 'rio/scheme/path'
#     end
#   end
#   autoload :StdIO, 'rio/scheme/stdio'
#   autoload :StdErr, 'rio/scheme/stderr'
#   autoload :Null, 'rio/scheme/null'
#   module Null
#     module Stream 
#       autoload :Open , 'rio/scheme/null'
#     end
#   end
#   autoload :Temp, 'rio/scheme/temp'
#   module Temp
#     autoload :Reset , 'rio/scheme/temp'
#     module Stream
#       autoload :Open , 'rio/scheme/temp'
#     end
#   end
#   autoload :StrIO, 'rio/scheme/strio'
#   module StrIO
#     module Stream
#       autoload :Open , 'rio/scheme/strio'
#     end
#   end
#   autoload :CmdPipe, 'rio/scheme/cmdpipe'
#   module CmdPipe
#     module Stream
#       autoload :Reset , 'rio/scheme/cmdpipe'
#     end
#   end
#   autoload :AryIO, 'rio/scheme/aryio'
#   autoload :HTTP, 'rio/scheme/http'
#   module HTTP
#     module Stream
#       autoload :Input , 'rio/scheme/http'
#       autoload :Open , 'rio/scheme/http'
#     end
#   end
#   autoload :FTP, 'rio/scheme/ftp'
#   autoload :TCP, 'rio/scheme/tcp'
#   autoload :SysIO, 'rio/scheme/sysio'
#   autoload :FD, 'rio/scheme/fd'
#   autoload :CmdIO, 'rio/scheme/cmdio'

# end
# module RIO
#   module Dir
#     autoload :Existing, 'rio/dir'
#     autoload :NonExisting, 'rio/dir'
#     autoload :Open , 'rio/dir'
#     autoload :Close , 'rio/dir'
#     autoload :Stream , 'rio/dir'
#   end
#   module File
#     autoload :NonExisting, 'rio/file'
#     autoload :Existing, 'rio/file'
#   end
# end
# module RIO
#   module Stream
#     autoload :Close , 'rio/stream/open'
#     autoload :Reset , 'rio/stream'
#     autoload :Open , 'rio/stream/open'
#     autoload :Input , 'rio/stream'
#     autoload :Output , 'rio/stream'
#     autoload :InOut , 'rio/stream'
#     module Duplex
#       autoload :Open , 'rio/stream/duplex'
#       autoload :Input , 'rio/stream/duplex'
#       autoload :Ouput , 'rio/stream/duplex'
#       autoload :InOut , 'rio/stream/duplex'
#       autoload :Close , 'rio/stream/duplex'
#       autoload :Reset , 'rio/stream/duplex'
#     end
#   end
# end






#      'Ext::YAML::Doc::Existing' , 'rio/ext/yaml/doc',
#      'Ext::YAML::Doc::Open' , 'rio/ext/yaml/doc',
#      'Ext::YAML::Doc::Stream' , 'rio/ext/yaml/doc',
#      'Ext::YAML::Doc::Close' , 'rio/ext/yaml/doc',




module RIO

  class Factory  #:nodoc: all
    include Singleton
    def initialize()
      @ss_module = {}
      @reset_class = {}
      @state_class = {}
      @ss_class = {}
    end

    def subscheme_module(sch)
      #p "subscheme_module(#{sch})"
      @ss_module[sch] ||= case sch
                          when 'file','path'
                            require 'rio/rrl/path'
                            Path
                          when 'zipfile'
                            require 'rio/ext/zipfile/rl'
                            ZipFile::RootDir
                          when 'stdio','stdin','stdout'
                            require 'rio/scheme/stdio'
                            StdIO
                          when 'stderr'
                            require 'rio/scheme/stderr'
                            StdErr
                          when 'null'
                            require 'rio/scheme/null'
                            Null
                          when 'tempfile'
                            require 'rio/scheme/temp'
                            Temp::File
                          when 'temp'
                            require 'rio/scheme/temp'
                            Temp
                          when 'tempdir'
                            require 'rio/scheme/temp'
                            Temp::Dir
                          when 'strio','stringio','string'
                            require 'rio/scheme/strio'
                            StrIO
                          when 'cmdpipe'
                            require 'rio/scheme/cmdpipe'
                            CmdPipe
                          when 'aryio'
                            require 'rio/scheme/aryio'
                            AryIO
                          when 'http','https'
                            require 'rio/scheme/http'
                            HTTP
                          when 'ftp'
                            require 'rio/scheme/ftp'
                            FTP
                          when 'tcp'
                            require 'rio/scheme/tcp'
                            TCP
                          when 'sysio'
                            require 'rio/scheme/sysio'
                            SysIO
                          when 'fd'
                            require 'rio/scheme/fd'
                            FD
                          when 'cmdio'
                            require 'rio/scheme/cmdio'
                            CmdIO
                          else
                            require 'rio/rrl/path'
                            Path
                          end
    end

    STATE2FILE = {
      'Path::Reset' => 'rio/path/reset',
      'Path::Empty' => 'rio/path',
      'Path::Str' => 'rio/path',
      'Path::NonExisting' => 'rio/path',

      'File::Existing' => 'rio/file',
      'File::NonExisting' => 'rio/file',

      'Dir::Existing' => 'rio/dir',
      'Dir::Open' => 'rio/dir',
      'Dir::Close' => 'rio/dir',
      'Dir::Stream' => 'rio/dir',
      'Dir::NonExisting' => 'rio/dir',

      'Stream::Close' => 'rio/stream/open',
      'Stream::Reset' => 'rio/stream',
      'Stream::Open' => 'rio/stream/open',
      'Stream::Input' => 'rio/stream',
      'Stream::Output' => 'rio/stream',
      'Stream::InOut' => 'rio/stream',

      'Stream::Duplex::Open' => 'rio/stream/duplex',
      'Stream::Duplex::Input' => 'rio/stream/duplex',
      'Stream::Duplex::Output' => 'rio/stream/duplex',
      'Stream::Duplex::InOut' => 'rio/stream/duplex',
      'Stream::Duplex::Close' => 'rio/stream/duplex',
      'Stream::Duplex::Reset' => 'rio/stream/duplex',

      'Path::Stream::Open' => 'rio/scheme/path',

      'StrIO::Stream::Open' => 'rio/scheme/strio',

      'Null::Stream::Open' => 'rio/scheme/null',

      'CmdPipe::Stream::Reset' => 'rio/scheme/cmdpipe',

      'HTTP::Stream::Input' => 'rio/scheme/http',
      'HTTP::Stream::Open' => 'rio/scheme/http',

      'Temp::Reset' => 'rio/scheme/temp',
      'Temp::Stream::Open' => 'rio/scheme/temp',

      'Ext::YAML::Doc::Existing' => 'rio/ext/yaml/doc',
      'Ext::YAML::Doc::Open' => 'rio/ext/yaml/doc',
      'Ext::YAML::Doc::Stream' => 'rio/ext/yaml/doc',
      'Ext::YAML::Doc::Close' => 'rio/ext/yaml/doc',


    }
    def riorl_class(sch)
      ssm = subscheme_module(sch)
      cls = ssm.const_get(:RRL)

      cls
    end

    def reset_state(rl)
      mod = subscheme_module(rl.scheme)
      mod.const_get(:RESET_STATE) unless mod.nil?
    end

    def state2class(state_name)
      return @state_class[state_name] if @state_class.has_key?(state_name)
      if STATE2FILE.has_key?(state_name)
        require STATE2FILE[state_name]
        return @state_class[state_name] = RIO.module_eval(state_name)
      else
        raise ArgumentError,"Unknown State Name (#{state_name})" 
      end
    end
    def try_state_proc1(current_state,rio_handle)
      proc { |new_state_name|
        _change_state(state2class(new_state_name,rio_handle),current_state,rio_handle)
      }
    end
    def try_state_proc(current_state,rio_handle)
      proc { |new_state_name|
        _change_state(state2class(new_state_name),current_state,rio_handle)
      }
    end

    def _change_state(new_state_class,current_state,rio_handle)
      # wipe out the reference to this proc so GC can get rid of rsc
      current_state.try_state = proc { 
        p "try_state for "+current_state.to_s+" used already??" 
        nil
      }
      new_state = new_state_class.new_other(current_state)
      new_state.try_state = try_state_proc(new_state,rio_handle)
      
      rio_handle.target = new_state
      return rio_handle.target
    end
    private :_change_state

    # factory creates a state from args
    def create_state(*args)
      riorl = RIO::RRL::Builder.build(*args)
      create_handle(state2class(reset_state(riorl)).new(rl: riorl))
    end
    def clone_state(state)
      create_handle(state.target.clone)
    end
    def create_handle(new_state)
      hndl = Handle.new(new_state)
      new_state.try_state = try_state_proc(new_state,hndl)
      hndl
    end

  end
end


if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__


