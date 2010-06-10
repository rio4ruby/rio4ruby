
require 'rio/fwd'
require 'rio/alturi'

module RIO
  class URIRef
    attr_reader :ref
    def initialize(u,b=nil)
      @ref = u
      @base = b
      #p "URIRef#initialize u=#{u} (#{u.class}),b=#{b} (#{b.class})"
      #puts caller[0,6]
      raise ArgumentError, "Either uri(#{u}) or base(#{b.inspect}) must be absolute" unless
        @ref.absolute? or @base.absolute?
    end
    def initialize_copy(other)
      super
      @ref = other.ref.clone
      @base = other.base.clone
    end
    def ==(other) ref == other.ref end
    def self.build(u,opts={})
      b = opts[:base]
      uref = case u
             when ::Alt::URI::Base then u
             when ::RIO::URIRef then u.ref
             else path_str_to_uri(u.to_s,opts)
             end
      ubase = case b
              when nil
                uref.absolute? ? uref : base_from_uref(uref)
              else
                calc_base(b)
              end
      new(uref,ubase)
    end
    def base
      @base
    end
    def self.calc_base(b)
      case b
      when ::Alt::URI::Base 
        b
      else
        base_str_to_uri(b.to_s)
      end
    end
    def base=(other)
      self.class.calc_base(other)
    end
    def self.base_from_uref(uref)
      buri = ::Alt::URI::Gen::URIParts.new
      buri.scheme = 'file'
      if uref.authority
        buri.authority = uref.authority
        buri.path = uref.path
      elsif uref.path.start_with?("/") or uref.path =~ %r{^[a-zA-Z]:}
        buri.path = uref.path
        buri.authority = ""
      else
        buri.path = ::Dir.getwd + "/"
        buri.authority = ""
      end
      ::Alt::URI::File.new(buri)
    end

    def self.path_str_to_uri(pth,opts={})
      cr_args = opts[:encoding] ? {:encoding => opts[:encoding]} : {} 
      #p cr_args
      case
      when pth.start_with?("//")
        ::Alt::URI.create(cr_args.merge(:netpath => pth))
      when (pth.start_with?("/") or (pth =~ %r{^[a-zA-Z]:}))
        ::Alt::URI.create(cr_args.merge(:path => pth))
      when pth =~ %r{^[a-zA-Z][a-zA-Z]+:}
        pth = "/" + pth if pth =~ /^[a-zA-Z]:/
        ::Alt::URI.parse(pth,opts)
      else
        ::Alt::URI.create(cr_args.merge(:path => pth))
      end
    end
    def self.base_str_to_uri(pth)
      case
      when pth.start_with?("//")
        ::Alt::URI.create(:scheme => 'file', :netpath => pth)
      when (pth.start_with?("/") or (pth =~ %r{^[a-zA-Z]:}))
        ::Alt::URI.create(:scheme => 'file', :authority => "", :path => pth)
      when (pth =~ %r{^[a-zA-Z0-9-][a-zA-Z0-9-]+:})
        pth = "/" + pth if pth =~ /^[a-zA-Z]:/
        ::Alt::URI.parse(pth)
      else
        raise ArgumentError, "Base(#{pth.inspect}) must be absolute"
      end
    end
    def abs(b=nil)
      if b.nil?
        self.class.build(ref.abs(base),:base => base)
      else
        self.class.build(ref,:base => b).abs
      end
    end
    def rel(b=nil)
      # p "uriref (#{self}).rel(#{b.inspect})"
      if b.nil?
       self.class.build(ref.rel(base),:base => base)
      else
        self.class.build(ref,:base => b).rel
      end
    end
    def route_from(b)
      # p "uriref (#{self}).route_from(#{b.inspect})"
      #self.class.build(abs.ref,b).rel
      self.class.build(abs.ref.route_from(b.ref),:base => b)
    end
    def route_to(b)
      #self.class.build(b,abs.ref).rel
      self.class.build(self.abs.ref.route_to(b.ref),:base => self.ref)
    end
    def join(*args)
      ref.join(*args)
      self
    end
    def to_s() ref.to_s end
    #extend Forwardable
    #extend Fwd
    #fwd :ref, :scheme, :authority, :path, :query, :fragment
    #fwd :ref, :host, :port, :userinfo, :user, :password
    #fwd :ref, :typecode
    #def_delegators :ref, :to_s, :normalize, :absolute?, :len gth
    #fwd :ref, :dirname,:basename,:filename,:extname
    #fwd :ref, :netpath,:fspath
    #fwd :ref, :ext
    def method_missing(sym,*args,&block)
      ref.__send__(sym,*args,&block)
    end
      
    def inspect()
      sprintf '#<URIRef:0x%0x @ref="%s" @base="%s">',self.object_id,@ref.to_s,@base.to_s
    end
  end

end


