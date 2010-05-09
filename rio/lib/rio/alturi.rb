require 'forwardable'
require 'rio/alturi/uri_parts'
require 'rio/alturi/algorithm'
require 'rio/fwd'

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
          sym = (k.to_s+?=).to_sym
          u.__send__(sym,v)
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
          parts[sym]
        end

        def []=(sym,val)
          parts[sym] = val
        end

        def absolute?
          parts.absolute?
        end

        def relative?
          parts.relative?
        end

        def abs(base)
          Alt::URI::Factory.from_parts(parts.abs(base.parts))
        end

        def rel(base)
          Alt::URI::Factory.from_parts(parts.rel(base.parts))
        end
        def route_from(other)
          self.rel(other)
        end
        def route_to(other)
          other.rel(self)
        end
        def join(*a)
          #p "A=#{a.inspect}"
          pthstr = a.map(&:to_s).join('/')
          #p "DODODODOD",a.map{ |ar| ar.is_a?(::String) ? "#{ar.encoding} #{ar}" : "#{ar}" }
          #p pthstr.encoding,pthstr
          newpth = (self.path + (a.empty? || self.path.empty? ? '' : '/') + pthstr).squeeze('/')
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
      extend RIO::Fwd
      attr_reader :parts
      attr_accessor :ext
      def initialize(parts)
        @parts = parts
        @ext = nil
      end
      def initialize_copy(other)
        @ext = other.ext
        super
        @parts = other.parts.dup
      end
      def ==(other) 
        @parts == other.parts 
      end
      def normalize
        self
      end
      def length
        self.to_s.length
      end
      def sub(re,arg)
        cp = self.clone
        cp.path = cp.path.sub(re,arg)
        cp
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
      def initialize(parts=nil)
        prts = parts || Alt::URI::Gen::URIParts.new
        super(prts)
      end
      def initialize_copy(other)
        super
      end
      def normalize
        
        #if self.host
        #  self.host = self.scheme ? "" : nil
        #end
        super
      end
      include Ops::Generic
      

      fwd :parts, :uri,:scheme,:path,:query,:fragment
      fwd :parts, :authority
      fwd :parts, :netpath
      fwd :parts, :host,:port
      fwd :parts, :userinfo
      fwd :parts, :user,:password
      def_delegators :parts, :to_s
      

      def netpath
        case self.scheme
        when nil,'file' then parts.netpath
        else path
        end
      end

      def netpath=(val)
        case self.scheme
        when 'file' then parts.netpath=(val)
        else path = val
        end
      end
      alias :fspath :netpath
      def fspath=(val) netpath = val end

      #      def abs(base)
      #        Alt::URI::Generic.new(parts.abs(base.parts))
      #      end
      #      def rel(base)
      #        Alt::URI::Generic.new(parts.rel(base.parts))
      #      end
    end

  end
end

module Alt
  module URI
    class File < ::Alt::URI::Base
      extend Forwardable
      extend Builders

      def initialize(parts=nil)
        prts = parts || Alt::URI::Gen::URIParts.new
        prts.scheme ||= 'file'
        prts.host ||= ""
        super(prts)
      end
      def initialize_copy(other)
        super
      end
      include Ops::Generic

      fwd :parts, :uri,:scheme,:path
      fwd :parts, :authority
      fwd :parts, :netpath
      fwd :parts, :host
      def_delegators :parts, :to_s
      
      def_delegators :parts, :uri,:authority,:scheme,:path
      def_delegators :parts, :uri=,:authority=,:scheme=,:path=,:host=,:netpath=,:host
      def_delegators :parts, :to_s

      def normalize
        hst = self.host if self.host and !(self.host == 'localhost' or self.host.empty?)
        ::Alt::URI.create(:host => hst, :path => self.path)
      end
      def netpath
        parts.netpath
      end
      def fspath
        normalize.netpath
      end
      def fspath=(val) netpath = val end

      def host=(val)
        parts.host = (val || "")
      end

      def authority=(val)
        self.host = val
      end

      def scheme=(val)
        parts.scheme = (val || 'file')
      end

      def path=(val)
        parts.path = val.nil? ? val : val.sub(Regexp.new(%{^([a-zA-Z]:)}),'/\1')
      end

      def path
        parts.path.sub(Regexp.new(%{^/([a-zA-Z]:)}),'\1')
      end

      def uri=(val)
        parts.uri = val
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

      def initialize(parts=nil)
        prts = parts || Alt::URI::Gen::URIParts.new
        prts.scheme ||= 'http'
        prts.host ||= ""
        super(prts)
      end
      def initialize_copy(other)
        super
      end
      include Ops::Generic

      fwd :parts, :uri,:scheme,:path,:query,:fragment
      fwd :parts, :authority
      fwd :parts, :netpath
      fwd :parts, :host,:port
      def_delegators :parts, :to_s
      
      def netpath
        parts.path
      end

      def netpath=(val)
        parts.path = val
      end
      alias :fspath :path
      def fspath=(val) path = val end

      def normalize
        if self.port == '80'
          self.port = nil
        end
        super
      end

      def host=(val)
        parts.host = (val || "")
      end

      def scheme=(val)
        parts.scheme = (val || 'http')
      end

    end

  end
end




module Alt
  module URI
    class FTP < ::Alt::URI::Base
      extend Forwardable
      extend Builders

      def initialize(parts=nil)
        prts = parts || Alt::URI::Gen::URIParts.new
        prts.scheme ||= 'ftp'
        prts.host ||= ""
        super(prts)
      end
      def initialize_copy(other)
        super
      end
      include Ops::Generic

      fwd :parts, :uri,:scheme,:path
      fwd :parts, :uri,:authority
      fwd :parts, :netpath
      fwd :parts, :host,:port
      fwd :parts, :userinfo
      fwd :parts, :user,:password
      def_delegators :parts, :to_s
      

      def fspath() self.path end
      def fspath=(val) self.path = val end

      def split_path_type
        if parts[:path] =~ %r{(.+);type=([ai])$}
          pth = $1
          typ = $2
        else
          pth = parts[:path]
          typ = nil
        end
        [pth,typ]
      end
      def path
        Alt::URI.unescape(split_path_type[0])[1..-1]
        #parts.path
      end
      def path=(val)
        pth = Alt::URI.escape(val,:path).sub(%r{^/},'%2F')
        typ = self.typecode
        escpath = "/#{pth}" + (typ ? ";type=#{typ}" : "")
        parts[:path] = escpath
      end
      
      def typecode
        split_path_type[1]
      end
      def typecode=(val)
        v = val.to_s
        raise ArgumentError,"typecode must be 'i' or 'a'" unless %w[i a].include?(v)
        parts[:path].sub!(/;type=[ia]$/,";type=#{v}") 
        val
      end
      def uri
        parts.uri
      end
      def uri=(val)
        parts.uri = val
      end

      
      







      def normalize
        if self.port == '21'
          self.port = nil
        end
        super
      end

      def host=(val)
        parts.host = (val || "")
      end

      def scheme=(val)
        parts.scheme = (val || 'ftp')
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
        when 'ftp'
          Alt::URI::FTP.new(u)
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
    def self.escape(str,fld)
      if str
        str.encode('UTF-8')
        Alt::URI::Escape.escape(str.force_encoding('US-ASCII'),fld) 
      end
    end
    def self.unescape(str)
      if str
        ustr = Alt::URI::Escape.unescape(str)
        @encoding ? ustr.force_encoding(@encoding) : ustr
      end
    end
  end
end

if __FILE__ == $0
  # TODO Generated stub
end
