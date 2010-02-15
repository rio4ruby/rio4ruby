
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
    def self.build(u,b=nil)
      uref = case u
             when ::Alt::URI::Base then u
             when ::RIO::URIRef then u.ref
             else path_str_to_uri(u.to_s)
             end
      ubase = case b
              when nil
                if uref.absolute?
                  uref
                else
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
              when ::Alt::URI::Base 
                b
              else
                base_str_to_uri(b.to_s)
              end
      new(uref,ubase)
    end
    def self.fileX(pth,b=nil)
      #p "self.file #{pth} b=#{b.inspect}"

      uref = case pth
          when ::Alt::URI::Base then pth
          else path_str_to_uri(pth.to_s)
          end
      ubase = case b
             when ::Alt::URI::Base then b
             when nil 
               if uref.absolute? 
                 uref 
               else
                 ::Alt::URI.create(:scheme => 'file', :authority => "", :path => ::Dir.getwd + "/")
               end
             else base_str_to_uri(b.to_s)
             end
            
      new(uref,ubase)
    end
    def initialize_copy(other)
      super
      @ref = other.ref.clone
      @base = other.base.clone
    end
    def base
      @base
    end
    def self.path_str_to_uri(pth)
      case
      when pth.start_with?("//")
        ::Alt::URI.create(:netpath => pth)
      when (pth.start_with?("/") or (pth =~ %r{^[a-zA-Z]:}))
        ::Alt::URI.create(:path => pth)
      when pth =~ %r{^[a-zA-Z][a-zA-Z]+:}
        ::Alt::URI.parse(pth)
      else
        ::Alt::URI.create(:path => pth)
      end
    end
    def self.base_str_to_uri(pth)
      case
      when pth.start_with?("//")
        ::Alt::URI.create(:scheme => 'file', :netpath => pth)
      when (pth.start_with?("/") or (pth =~ %r{^[a-zA-Z]:}))
        ::Alt::URI.create(:scheme => 'file', :authority => "", :path => pth)
      when (pth =~ %r{^[a-zA-Z0-9-][a-zA-Z0-9-]+:})
        ::Alt::URI.parse(pth)
      else
        raise ArgumentError, "Base(#{pth.inspect}) must be absolute"
      end
    end
    def abs(b=nil)
      if b.nil?
        self.class.build(ref.abs(base),base)
      else
        self.class.build(ref,b).abs
      end
    end
    def rel(b=nil)
      if b.nil?
       self.class.build(ref.rel(base),base)
      else
        self.class.build(ref,b).rel
      end
    end
    def route_from(b)
      self.class.build(abs.ref,b).rel
    end
    def route_to(b)
      self.class.build(b,abs.ref).rel
    end
    def join(*args)
      ref.join(*args)
      self
    end
    extend Forwardable
    extend Fwd
    fwd :ref, :scheme, :authority, :path, :query, :fragment, :host, :port, :userinfo
    def_delegators :ref, :to_s, :normalize, :absolute?, :length
    fwd :ref, :dirname,:basename,:filename,:extname
    fwd :ref, :netpath,:fspath
    def inspect()
      sprintf '#<URIRef:0x%0x @ref="%s" @base="%s">',self.object_id,@ref.to_s,@base.to_s
    end
  end

end

