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


require 'rio/alturi'
require 'rio/local'
require 'rio/rl/base'
require 'rio/rrl/base'
require 'stringio'

module RIO
  module RL
    class Builder
      def self.build_path_rl(rl)
        return rl
      end
      def self.build(*a)
        #puts "build: #{a.inspect}" 
        a.flatten!
        a.push('') if a.empty?
        case a[0]
        when ?? , ?= , ?_ , ?", ?[, ?#, ?`, ?|, ?z
          a[0] = 'rio:'+CHMAP[a[0]]+':'
        when ?-
          a[0] = ( a.size == 1 ? 'rio:'+CHMAP[a[0]]+':' : 'rio:cmdio:' )
        when ?$
          a[0] = 'rio:strio:'
        when ::String
          case a[0]
          when /^[a-zA-Z]:/
            a[0] = 'rio:file:///'+a[0]
          when /^[a-z][a-z]+:/
            a[0] = 'rio:'+a[0] unless a[0] =~ /^rio:/
          when %r|^//|
            a[0] = 'rio:file:'+a[0]
          when %r|^/|
            #a[0] = 'file://'+a[0]
              #p "IN BUILDER #{a.inspect}"
            return Factory.instance.riorl_class('file').new(*a)
          else
            return Factory.instance.riorl_class('path').new(*a)
          end
        when RIO::Rio
          #p "BUILD: a[0]=#{a[0].inspect} a[0].rl=#{a[0].rl.inspect}"
          a[0] = a[0].rl
          return build(*a)
        when RL::Base
          #p "BUILD: RL::Base a=#{a.inspect}"
          a0 = a.shift.clone
          cl = Factory.instance.riorl_class(a0.scheme)
          o = cl.new(a0,*a) unless cl.nil?
          return o
          #          return (a.empty? ? a0 : a0.join(*a))
        when ::RIO::RRL::Base
          #p "BUILD: RRL::Base a=#{a.inspect}"
          a0 = a.shift.uri
          cl = Factory.instance.riorl_class(a0.scheme)
          o = cl.new(a0,*a) unless cl.nil?
          return o
          #          return (a.empty? ? a0 : a0.join(*a))
        when ::Alt::URI::Base
          a0 = a.shift
          #p "SCHEME is #{a0.scheme}"
          cl = Factory.instance.riorl_class(a0.scheme)
          o = cl.new(a0,*a) unless cl.nil?
          return o
        when ::Symbol
          case a[0]
          when :zpath
            a0 = a.shift
            cl = Factory.instance.riorl_class(a0.to_s)
            o = cl.new(*a) unless cl.nil?
            return o
          else
            a[0] = 'rio:' + a[0].to_s + ':'
          end
        when ::NilClass
          a[0] = 'rio:null:'
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
        #p "cl=#{cl}"
        cl.parse(a0,*a)  unless cl.nil?

      end

    end
  end
end
