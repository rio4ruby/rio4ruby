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


require 'extensions/object'
require 'rio/grande'
require 'rio/cp'
module RIO
  module Impl
    module U
      def self.rmdir(s) ::Dir.rmdir(s.to_s) end
      def self.mkdir(s,*args) ::Dir.mkdir(s.to_s,*args) end
      def self.chdir(s,&block) ::Dir.chdir(s.to_s,&block) end
      def self.foreach(s,&block) ::Dir.foreach(s.to_s,&block) end
      def self.entries(s) ::Dir.entries(s.to_s) end
      def self.cp_r(s,d)
        require 'fileutils'
        ::FileUtils.cp_r(s.to_s,d.to_s)
      end
      def self.find(s,&block) 
        require 'find'
        Find.find(s.to_s) do |f|
          yield f
        end
      end
      def self.glob(gstr,*args,&block) 
        ::Dir.glob(gstr,*args,&block) 
      end
      def self.rmtree(s)
        require 'fileutils'
        ::FileUtils.rmtree(s.to_s)
      end
      def self.mkpath(s) 
        require 'fileutils'
        ::FileUtils.mkpath(s.to_s) 
      end
    end
  end

  module Ops
    module Dir
      module ExistOrNot
        require 'rio/ops/either'
        include ::RIO::Ops::FileOrDir::ExistOrNot
      end
    end
  end
  module Ops
    module Dir
      module NonExisting
        include ExistOrNot
        include ::RIO::Ops::FileOrDir::NonExisting
        def mkdir(*args)
          #          p callstr('mkdir',*args)
          Impl::U.mkdir(self,*args); 
          softreset() 
        end
        def mkpath(*args) 
          #          p callstr('mkpath',*args)
          Impl::U.mkpath(self,*args); 
          softreset()
        end
        def rmdir(*args) self end
        def rmtree(*args) self end
        alias :delete :rmdir
        alias :unlink :rmdir
        alias :delete! :rmtree
      end
    end
  end
end
module RIO
  module Ops
    module Dir
      module Existing
        include ExistOrNot
        include FileOrDir::Existing
        include Cp::Dir::Input
        include Cp::Dir::Output
      end
    end
  end
end



module RIO
  module Ops
    module Dir
      module Existing
        def selective?
          %w[entry_sel stream_sel stream_nosel].any? { |k| cx.has_key?(k) }
        end
        def mkdir(*args) self end
        def mkpath(*args) self end
        def rmdir(*args) 
          Impl::U.rmdir(self,*args); 
          softreset()
        end
        def rmtree(*args) Impl::U.rmtree(self,*args); softreset() end

        alias :delete :rmdir
        alias :delete! :rmtree
        alias :unlink :rmdir

        def chdir(*args,&block) 
          if block_given?
            Impl::U.chdir(self,*args) { |dir|
              yield new_rio('.')
            }
          else
            Impl::U.chdir(self,*args)
            return new_rio('.')
          end
          self
        end

        def ensure_rio_cx(arg0)
          return arg0 if arg0.kind_of?(::RIO::Rio)
          new_rio_cx(arg0)
        end

        def glob(*args,&block) 
          chdir do
            if block_given?
              Impl::U.glob(*args) do |ent|
                yield new_rio_cx(self,ent)
              end
            else
              return Impl::U.glob(*args).map { |ent| new_rio_cx(self,ent) }
            end
          end
        end

      end
    end
  end
  module Ops
    module Dir
      module Stream
        include FileOrDir::Existing
        include Enumerable
        include Grande
        include Cp::Dir::Input
        include Cp::Dir::Output
        public

        def entries(*args,&block) _set_select('entries',*args,&block) end

        def each(*args,&block)
          # p callstr('each',*args)
          each_(*args,&block)
        end


        def read() 
          read_()
        end

        def rewind() ioh.rewind(); self end
        def seek(integer) ioh.seek(integer); self end

        extend Forwardable
        def_instance_delegators(:ioh,:tell,:pos,:pos=)

        protected
        require 'rio/entrysel'
      end
    end
  end
end
module RIO
  module Ops
    module Dir
      module Stream

        protected

        def read_() 
          if ent = ioh.read()
            new_rio_cx(ent) 
          else
            self.close if closeoneof?
            nil
          end
        end
        def process_skipped
          return unless cx.has_key?('skip_args') or cx['skipping']
          args = cx['skip_args'] || []
          skip_meth = 'skipentries'
#          skip_meth = ss_type?(_ss_keys)
          self.__send__(skip_meth,*args)
        end
        def each_(*args,&block)
          #p "#{callstr('each_',*args)} sel=#{cx['sel'].inspect} nosel=#{cx['nosel'].inspect}"
          process_skipped()
          sel = Match::Entry::Selector.new(cx['entry_sel'])
          selfstr = (self.to_s == '.' ? nil : self.to_s)
          self.ioh.each do |estr|
            next if estr =~ /^\.(\.)?$/
            begin
              erio = new_rio_cx(selfstr ? Impl::U.join(selfstr,estr) : estr )
 
              if stream_iter?
                _add_stream_iter_cx(erio).each(&block) if erio.file? and sel.match?(erio)
              else
                yield _add_iter_cx(erio) if sel.match?(erio)
              end

              if cx.has_key?('all') and erio.directory?
                rsel = Match::Entry::SelectorClassic.new(cx['r_sel'],cx['r_nosel'])
                _add_recurse_iter_cx(erio).each(&block) if rsel.match?(erio)
              end
              
            rescue ::Errno::ENOENT, ::URI::InvalidURIError => ex
              $stderr.puts(ex.message+". Skipping.")
            end
          end
          closeoneof? ? self.close : self
        end

      end
    end
  end
end

module RIO
  module Ops
    module Dir
      module Stream

        private

        def _ss_keys()  Cx::SS::ENTRY_KEYS + Cx::SS::STREAM_KEYS end
        CX_ALL_SKIP_KEYS = ['retrystate']
        def _add_recurse_iter_cx(ario)
          new_cx = ario.cx
          cx.keys.reject { |k| 
            CX_ALL_SKIP_KEYS.include?(k) 
          }.each { |k|
            new_cx.set_(k,cx[k])
          }
          ario.cx = new_cx
          ario
        end
        def _add_cx(ario,keys)
          new_cx = ario.cx
          keys.each {|k|
            next unless cx.has_key?(k)
            new_cx.set_(k,cx[k])
          }
          ario.cx = new_cx
        end
        CX_DIR_ITER_KEYS = %w[entry_sel]
        CX_STREAM_ITER_KEYS = %w[stream_rectype stream_itertype stream_sel stream_nosel]
        def _add_iter_cx(ario)
          if nostreamenum?
            _add_cx(ario,CX_DIR_ITER_KEYS)
          end
          _add_stream_iter_cx(ario)
        end
        def _add_stream_iter_cx(ario)
          _add_cx(ario,CX_STREAM_ITER_KEYS)
          new_cx = ario.cx
          if stream_iter?
            new_cx.set_('ss_args',cx['ss_args']) if cx.has_key?('ss_args')
            new_cx.set_('ss_type',cx['ss_type']) if cx.has_key?('ss_type')
          end
          ario.cx = new_cx
          ario
        end
      end
    end
  end
end
