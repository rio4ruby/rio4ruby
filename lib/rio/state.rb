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


#require 'rio/context'
#require 'rio/context/methods'
#require 'rio/ext'
#require 'rio/filter'
#require 'rio/fs/native'
#require 'rio/fwd'

require 'rio/exception/state'
require 'rio/state/data'
require 'rio/symantics'
module RIO
  autoload :Cx,'rio/context'
  autoload :Ext,'rio/ext'
end

module RIO

                   
  module State #:nodoc: all
    # = State
    # the abstract state from which all are derived
    # this level handles 
    # * some basic house keeping methods
    # * the methods to communicate with the rio object
    # * the state changing mechanism
    # * and some basic error handling stubs
    class Base
      kiosyms = []
      kiosyms << :gets
      kiosyms << :open
      kiosyms << :readline
      kiosyms << :readlines
      kiosyms << :putc
      kiosyms << :puts
      kiosyms << :print
      kiosyms << :printf
      kiosyms << :=~
      kiosyms << :===
      kiosyms << :==
      kiosyms << :eql?
      kiosyms << :load
      kiosyms << :to_a
      #kiosyms << :split
      #kiosyms << :sub
      #kiosyms << :sub!
      #kiosyms << :gsub
      #kiosyms << :gsub!
      #kiosyms << :chop
      #kiosyms << :getc

      # In 1.8 #to_a is inherited from Object
      # For 1.9 we create this -- only to undef it immediatly.
      # So we end up in the same state for both ruby versions.
      def to_a() end

      KIOSYMS = kiosyms
      @@kernel_cleaned ||= KIOSYMS.each { |sym| undef_method(sym) } 
      undef_method(:rio)
    end 
    
    class Base
      attr_accessor :try_state
      #attr_accessor :handled_by

      # include Enumerable
      # Context handling
      include Cx::Methods
      include RIO::Ext::Cx

      
      attr_reader :data
      def initialize(iv)
        #p "State#initialize(#{iv.keys.inspect})"
        @data = State::Data.new
        iv.keys.each do |k|
          @data[k] = iv[k]
        end
        @data.cx ||= self.class.default_cx
      end
      
      def initialize_copy(other)
        super
        @data = State::Data.new
        data.rl = other.data.rl.clone if other.data.rl
        data.cx = other.data.cx.clone if other.data.cx
        data.ioh = other.data.ioh.clone if other.data.ioh
      end

      extend Forwardable
      def_instance_delegators(:rl,:path,:netpath,:to_s,:fspath,:length)

      extend RIO::Fwd
      fwd :data,:rl,:cx
      fwd :data,:ioh
      alias :ior :ioh
      alias :iow :ioh

      def self.default_cx
         Cx::Vars.new( { 'closeoneof' => true, 'closeoncopy' => true } )
      end
      def self.new_other(other)
        new(other.data)
      end





      # Section: State Switching

      # the method for changing states
      # it's job is create an instance of the next state
      # and change the value in the handle that is shared with the rio object
      def become(new_class,*args)
        p "become : #{self.class.to_s} => #{new_class.to_s} (#{self.mode?})" if $trace_states
        #p "BECOME #{new_class}: #{cx['ss_type']}"
        return self if new_class == self.class

        new_state = try_state[new_class,*args]
        became(new_state)
        new_state
      end
      def became(obj)
        #RIO::Ext.became(obj)
      end
      def method_missing_trace_str(sym,*args)
        # "missing: "+self.class.to_s+'['+self.to_url+" {#{self.rl.fs}}"+']'+'.'+sym.to_s+'('+args.join(',')+')'
          "missing: "+self.class.to_s+'['+self.to_url+']'+'.'+sym.to_s+'('+args.join(',')+')'
        #"missing: "+self.class.to_s+'['+self.to_url+""+']'+'.'+sym.to_s+'('+args.join(',')+')'
      end

      def method_missing(sym,*args,&block)
        p method_missing_trace_str(sym,*args) if $trace_states

        obj = when_missing(sym,*args)
        raise RuntimeError,"when_missing returns nil" if obj.nil?
        #p "STATE: METHOD_MISSING",obj.to_s,sym,args
        obj.__send__(sym,*args,&block) #unless obj == self
      end
      
      def when_missing(sym,*args) gofigure(sym,*args) end


      def base_state() Factory.instance.reset_state(rl) end

      def softreset 
        #p "softreset(#{self.class}) => #{self.base_state}"
        cx['retrystate'] = nil
        become(self.base_state) 
      end
      def retryreset 
        #p "retryreset(#{self.class}) => #{self.base_state}"
        become(self.base_state) 
      end
      def reset
        softreset()
      end

      # Section: Error Handling
      def gofigure(sym,*args)
        cs = "#{sym}("+args.map{|el| el.to_s}.join(',')+")"
        msg = "Go Figure! rio('#{self.to_s}').#{cs} Failed"
        error(msg,sym,*args)
      end

      def error(emsg,sym,*args)
        require 'rio/state/error'
        Error.error(emsg,self,sym,*args)
      end

      def to_rl() self.rl.rl end
      def fs() self.rl.fs end

      #def_instance_delegators(:uri,:path,:netpath,:to_s,:fspath,:length)

      def ==(other) rl == other end
      def ===(other) self == other end
      def =~(other) other =~ self.to_str end
      def to_url() rl.url end
      def to_uri() rl.uri end
      def uri() rl.uri end
      alias :to_str :to_s
      alias :to_path :to_s
      def to_ary() nil end

      def hash() rl.to_s.hash end
      #def eql?(other) @rl.to_s.eql?(other.to_s) end

      def stream?() false end

      # Section: Rio Interface
      # gives states the ability to create new rio objects
      # (should this be here???)
      def new_rio(arg0,*args,&block)
        Rio.rio(arg0,*args,&block)
      end
      def new_rio_cx(*args)
        n = new_rio(*args)
        n.cx = self.cx.bequeath(n.cx)
        n
      end
      def clone_rio()
        cp = Rio.new(self.rl)
        cp.cx = self.cx.clone
        #cp.ioh = self.ioh.clone unless self.ioh.nil?
        cp.rl = self.rl.clone
        cp
      end
      
      def ensure_rio(arg0)
        case arg0
        when RIO::Rio then arg0
        when RIO::State::Base then arg0.clone_rio
        else new_rio(arg0)
        end
      end
      def ensure_cmd_rio(arg)
        case arg
        when ::String then new_rio("cmdio:"+arg)
        when ::Fixnum then new_rio(arg)
        when Rio then arg.clone
        else ensure_rio(arg)
        end
      end

      include Symantics

      def callstr(func,*args)
        self.class.to_s+'['+self.to_url+']'+'.'+func.to_s+'('+args.join(',')+')'
      end

    end

  end

end # module RIO
