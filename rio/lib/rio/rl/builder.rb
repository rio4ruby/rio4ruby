#--
# =============================================================================== 
# Copyright (c) 2005, Christopher Kleckner
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
#  rake rdoc
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


require 'uri'
require 'rio/local'
require 'rio/rl/base'
require 'stringio'

module RIO
  module RL
    class Builder

      def self.canon(a)
        #puts "canon: #{a.inspect}" 
        case a[0]
        when ::String
          case a[0]
          when /^[a-z][a-z]+:/
            a[0] = 'rio:'+a[0] unless a[0] =~ /^rio:/
            a
          when %r|^/|
            a[0] = 'rio:file://'+a[0]
            a
          else
            a[0] = 'rio:path:'+a[0]
            a
          end
        when RIO::Rio
          a[0] = a[0].to_rl
          canon(a)
        when RL::Base
          a
        when ::URI
          a
        when ?? , ?= , ?_ , ?",?[,?#,?`
          a[0] = 'rio:'+CHMAP[a[0]]+':'
          a
        when ?-
          a[0] = ( a.size == 1 ? 'rio:'+CHMAP[a[0]]+':' : 'rio:cmdio:' )
          a
        when ?$
          a[0] = 'rio:strio:'
          a
        when ::IO
          a.unshift('rio:sysio:')
          a
        when ::StringIO
          a.unshift('rio:strio:')
          a
        else
          a[0] = a[0].to_s
          canon(a)
        end
      end


      def self.build(*a)
        #puts "build: #{a.inspect}" 
        a.flatten!
        case a[0]
        when ::String
          case a[0]
          when /^[a-z][a-z]+:/
            a[0] = 'rio:'+a[0] unless a[0] =~ /^rio:/
          when %r|^/|
            a[0] = 'file://'+a[0]
            return Factory.instance.riorl_class('file').new(*a)
          else
            return Factory.instance.riorl_class('path').new(*a)
          end
        when RIO::Rio
          a[0] = a[0].to_rl
        when RL::Base
          #p 'heeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
          a0 = a.shift
        return a0.class.new(a0.uri.dup,*a)
        when ::URI
          a0 = a.shift
          cl = Factory.instance.riorl_class(a0.scheme)
          o = cl.new(a0,*a) unless cl.nil?
          return o
        when ::Symbol
          a[0] = 'rio:' + a[0].to_s + ':'
        when ?? , ?= , ?_ , ?", ?[, ?#, ?`
          a[0] = 'rio:'+CHMAP[a[0]]+':'
        when ?-
          a[0] = ( a.size == 1 ? 'rio:'+CHMAP[a[0]]+':' : 'rio:cmdio:' )
        when ?$
          a[0] = 'rio:strio:'
        when ::IO
          a.unshift('rio:sysio:')
        when ::StringIO
          a.unshift('rio:strio:')
        else
          a[0] = a[0].to_s
          return build(*a)
        end
        a0 = a.shift
        sch = Base.subscheme(a0)
        cl = Factory.instance.riorl_class(sch)
        cl.parse(a0,*a)  unless cl.nil?

      end


      def self.build0(*args)
        #p "build(#{args.inspect})"

        # aryio is a special case -- must not flatten
        if args[0] == 'rio:aryio'
          args.shift
          ary = args[0] unless args.empty? 
          require 'rio/scheme/aryio'
          return RIO::AryIO::RL.new(ary)
        end

        args = canon(args.flatten)
        a0 = args.shift
        case a0
        when RL::Base
          a0.class.new(a0.uri.dup,*args)
        when ::URI
          cl = Factory.instance.riorl_class(a0.scheme)
          cl.new(a0,*args) unless cl.nil?
        else
          sch = Base.subscheme(a0)
          cl = Factory.instance.riorl_class(sch)
          cl.parse(a0,*args)  unless cl.nil?
        end
      end

    end
  end
end
