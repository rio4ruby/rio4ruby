require 'forwardable'
require 'rio/alturi/uri_parts'
require 'rio/alturi/algorithm'

module Alt
  module URI
    module Builders
      def parse_(str,&block)
        u = self.new
        u.uri = str
        yield u if block_given?
        u
      end

      def parse(str)
        parse_(str)
      end

      def create_(hash)
        u = self.new
        hash.each do |k,v|
          u[k.to_sym] = v
        end
        u
      end

      def create(hash=nil)
        hash ||= Hash.new
        create_(hash)
      end
    end
  end
end
module Alt
  module URI
    module Ops
      module PathParts
        def netpath
          _netpath_scheme
        end

        private

        def _netpath_scheme
          if !parts.scheme or parts.scheme != 'file'
            _netpath_host
          else
            _netpath_path
          end
        end

        def _netpath_path
          parts.path
        end
        def _netpath_host_str
          '//' + parts.host + ( parts.path.empty? ? "" : _netpath_path )          
        end
        def _netpath_host
          if parts.host
            if parts.scheme.nil? or parts.scheme == 'file'
              if parts.host.empty? or parts.host == 'localhost'
                _netpath_path
              else
                _netpath_host_str
              end
            else
              _netpath_path
            end
          else
            _netpath_path
          end
        end

      end
    end
  end
end


module Alt
  module URI
    module Ops
      module Generic
        def [](sym)
          __send__(sym)
        end

        def []=(sym,val)
          __send__(sym.to_s+'=',val)
        end

        def absolute?
          @parts.absolute?
        end

        def relative?
          @parts.relative?
        end

        def abs(base)
          Alt::URI::Factory.from_parts(@parts.abs(base.parts))
        end

        def rel(base)
          Alt::URI::Factory.from_parts(@parts.rel(base.parts))
        end
        def route_from(other)
          self.rel(other)
        end
        def route_to(other)
          other.rel(self)
        end
        def join(*a)
          pthstr = a.map(&:to_s).join('/')
          #p "DODODODOD",a.map{ |ar| ar.is_a?(::String) ? "#{ar.encoding} #{ar}" : "#{ar}" }
          #p pthstr.encoding,pthstr
          newpth = (self.path + (!a.empty? ? '/' : '') + pthstr).squeeze('/')
          #p "NEWPATH:",newpth.encoding,newpth
          self.path = newpth
        end

      end
    end
  end
end
require 'rio/alturi/path_parts'
module Alt
  module URI
    class Base
      def initialize
        @ext = nil
      end
      def initialize_copy(other)
        @ext = other.ext
        super
      end
      def ext()
        @ext
      end
      def ext=(arg)
        @ext = arg
      end
      def normalize
        self
      end
      def length
        self.to_s.length
      end
      include ::Alt::URI::Ops::PathParts
    end
  end
end
module Alt
  module URI
    class Generic < ::Alt::URI::Base
      extend Forwardable
      extend Builders
      attr_reader :parts
      def initialize(parts=nil)
        @parts = parts || Alt::URI::Gen::URIParts.new
        super()
      end
      def initialize_copy(other)
        super
        @parts = other.parts.dup
      end
      def normalize
        
        #if self.host
        #  self.host = self.scheme ? "" : nil
        #end
        super
      end
      include Ops::Generic
      
      def_delegators :@parts, :uri,:authority,:scheme,:path,:fragment
      def_delegators :@parts, :uri=,:authority=,:scheme=,:path=,:query=,:fragment=,:query
      def_delegators :@parts, :userinfo,:host
      def_delegators :@parts, :userinfo=,:host=,:port=, :port
      def_delegators :@parts, :to_s
      

      def sub(re,arg)
        cp = self.clone
        cp.path = cp.path.sub(re,arg)
        cp
      end

      def netpath
        case self.scheme
        when nil,'file' then @parts.netpath
        else path
        end
      end

      def netpath=(val)
        case self.scheme
        when 'file' then @parts.netpath=(val)
        else path = val
        end
      end
      alias :fspath :netpath
      alias :fspath= :netpath=

      #      def abs(base)
      #        Alt::URI::Generic.new(@parts.abs(base.parts))
      #      end
      #      def rel(base)
      #        Alt::URI::Generic.new(@parts.rel(base.parts))
      #      end
    end

  end
end

module Alt
  module URI
    class File < ::Alt::URI::Base
      extend Forwardable
      extend Builders

      attr_reader :parts
      def initialize(parts=nil)
        @parts = parts || Alt::URI::Gen::URIParts.new
        @parts.scheme ||= 'file'
        @parts.host ||= ""
        super()
      end
      def initialize_copy(other)
        super
        @parts = other.parts.dup
      end
      include Ops::Generic

      def_delegators :@parts, :uri,:authority,:scheme,:path
      def_delegators :@parts, :uri=,:authority=,:scheme=,:path=
      def_delegators :@parts, :host
      def_delegators :@parts, :host=
      def_delegators :@parts, :to_s, :netpath=

      def normalize
        hst = self.host if self.host and !(self.host == 'localhost' or self.host.empty?)
        ::Alt::URI.create(:host => hst, :path => self.path)
      end
      def netpath
        @parts.netpath
      end
      def fspath
        normalize.netpath
      end
      alias :fspath= :netpath=

      def host=(val)
        @parts.host = (val || "")
      end

      def authority=(val)
        self.host = val
      end

      def scheme=(val)
        @parts.scheme = (val || 'file')
      end

      def path=(val)
        @parts.path = val.nil? ? val : val.sub(Regexp.new(%{^([a-zA-Z]:)}),'/\1')
      end

      def path
        @parts.path.sub(Regexp.new(%{^/([a-zA-Z]:)}),'\1')
      end

      def uri=(val)
        @parts.uri = val
        self.scheme ||=nil
        self.host ||=nil
      end
    end
  end
end

module Alt
  module URI
    class HTTP < ::Alt::URI::Base
      extend Forwardable
      extend Builders

      attr_reader :parts
      def initialize(parts=nil)
        @parts = parts || Alt::URI::Gen::URIParts.new
        @parts.scheme ||= 'http'
        @parts.host ||= ""
        super()
      end
      def initialize_copy(other)
        super
        @parts = other.parts.dup
      end
      include Ops::Generic

      def_delegators :@parts, :uri,:authority,:scheme,:path,:query,:fragment
      def_delegators :@parts, :uri=,:authority=,:scheme=,:path=,:query=,:fragment=
      def_delegators :@parts, :host,:port
      def_delegators :@parts, :host=,:port=
      def_delegators :@parts, :to_s
      def netpath
        @parts.path
      end

      def netpath=(val)
        @parts.path = val
      end
      alias :fspath :path
      alias :fspath= :path=

      def normalize
        if self.port == '80'
          self.port = nil
        end
        super
      end

      def host=(val)
        @parts.host = (val || "")
      end

      def scheme=(val)
        @parts.scheme = (val || 'http')
      end

    end

  end
end











module Alt
  module URI
    module Factory
      def self.from_parts(u)
        case u.scheme
        when 'file'
          Alt::URI::File.new(u)
        when 'http'
          Alt::URI::HTTP.new(u)
        else
          Alt::URI::Generic.new(u)
        end
      end

      def self.parse(str)
        u = Alt::URI::Gen::URIParts.parse(str)
        from_parts(u)
      end

      def self.create(hash)
        u = Alt::URI::Gen::URIParts.create(hash)
        from_parts(u)
      end
    end
  end
end
module Alt
  module URI
    def self.parse(str)
      Factory.parse(str)
    end
    def self.create(hash)
      Factory.create(hash)
    end
  end
end

if __FILE__ == $0
  # TODO Generated stub
end
