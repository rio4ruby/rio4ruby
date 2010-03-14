require 'forwardable'
require 'rio/alturi/escape'
require 'rio/alturi/parse'
require 'rio/alturi/algorithm'
#require 'rio/alturi/cached_fields'

module Alt
  module URI
    class FieldStore
      extend Forwardable
      def initialize(hash)
        @hash = hash
      end

      def_delegators :@hash, :[]=, :[], :values_at

      def method_missing(sym,*args,&block)
        if sym.to_s.end_with? '='
          @hash[sym] = args[0]
        else
          @hash[sym]
        end
      end
    end

  end
end

module Alt
  module URI
    module Gen
      class URIString
        attr_reader :path
        def initialize(scheme,authority,path,query,fragment)
          @scheme = scheme
          @authority = authority
          @path = path
          @query = query
          @fragment = fragment
        end

        def scheme
          @scheme + ':' if @scheme
        end

        def authority
          '//' + @authority if @authority
        end

        def query
          '?' + @query if @query
        end

        def fragment
          '#' + @fragment if @fragment
        end

        def to_s
          "#{scheme}#{authority}#{path}#{query}#{fragment}"
        end
      end
    end
  end
end

module Alt
  module URI
    module Gen
      class AuthParts
        attr_reader :host
        def initialize(userinfo,host,port)
          @userinfo = userinfo
          @host = host
          @port = port
        end

        def userinfo
          @userinfo + '@' if @userinfo
        end

        def port
          ':' + @port if @port
        end

        def to_s
          "#{userinfo}#{host}#{port}"
        end
      end

    end
  end
end

module Alt
  module URI
    module Gen
      class URIParts
        attr_reader :store,:encoding
        def initialize
          @store = { :path => "" }
          # @encoding = @store[:path].encoding
          #p __ENCODING__
          #@encoding = Encoding.default_internal
          @encoding = Encoding.find('UTF-8')
        end

        def initialize_copy(other)
          super
          @store = other.store.dup
          @encoding = other.encoding
        end
        def ==(other)
          @store == other.store
        end
        def store
          @store
        end

        def self.parse(str)
          u = URIParts.new
          u.uri = str
          u
        end

        def self.create(hash)
          u = URIParts.new
          hash.each do |k,v|
            u.__send__(k.to_s+'=',v)
          end
          u
        end

        def [](sym)
          __send__(sym)
        end

        def []=(sym,val)
          __send__(sym.to_s+'=',val)
        end

        def nil_or(val,dflt=nil,&block)
          return dflt unless val
          yield val
        end

        def fragment=(val)
          @store[:fragment] = nil_or(val) { |v| _do_esc(v,:fragment) }
        end

        def scheme=(val)
          @store[:scheme] = nil_or(val) { |v| v.downcase }
        end
        def _do_esc(str,fld)
          str.encode('UTF-8')
          Alt::URI::Escape.escape(str.force_encoding('US-ASCII'),fld) 
        end
        def _do_unesc(str)
          if str
            ustr = Alt::URI::Escape.unescape(str)
            @encoding ? ustr.force_encoding(@encoding) : ustr
          end
        end
        def path=(val)
          @store[:path] = nil_or(val,"") { |v| 
            # @encoding = v.encoding
            _do_esc(v,:path) 
          }
        end
        def path
          _do_unesc(@store[:path])
        end


        def query=(val)
          @store[:query] = nil_or(val) { |v|
            if v.instance_of?(::Array)  
              v.map { |el| 
                _do_esc(el,:query_part) 
              }.join('&') 
            else 
              _do_esc(v,:query)
            end
          }
        end
        def query
          if @store[:query]
            qparts = @store[:query].split('&',-1)
            if qparts.size > 1
              qparts.map { |el| _do_unesc(el) }
            elsif qparts.size == 1
              _do_unesc(qparts[0])
            else
              ""
            end
          end
        end

        def userinfo=(val)
          @store[:userinfo] = nil_or(val) { |v| _do_esc(v,:userinfo) }
        end

        def port=(val)
          @store[:port] = nil_or(val) { |v| v.to_s }
        end

        def host=(val)
          @store[:host] = if !val
                            @store[:userinfo] = @store[:port] = nil
                          else
                            nil_or(val) { |v| v.downcase }
                          end
        end

        def scheme
          @store[:scheme]
        end

        def host
          _do_unesc(@store[:host])
        end

        def port
          @store[:port] 
        end


        def fragment
          _do_unesc(@store[:fragment]) if @store[:fragment]
        end

        def userinfo
          _do_unesc(@store[:userinfo]) if @store[:userinfo]
        end

        def uri
          self.to_s
        end


        def authority
          AuthParts.new(*(@store.values_at(:userinfo,:host,:port))).to_s if @store[:host]
        end

        def authority=(val)
          if !val
            @store[:userinfo] = @store[:host] = @store[:port] = nil
          else
            Alt::URI::Parse::RE_AUTHORITY.match(val) { |m|
              self.host = m[:host]
              self.port = m[:port]
              @store[:userinfo] = m[:userinfo]
            }
          end
        end

        def uri=(val)
          if !val
            @store.clear
            @store[:path] = ""
          else
            Alt::URI::Parse::RE_GENERIC.match(val) { |m|
              self.scheme = m[:scheme]
              self.authority = m[:authority]
              @store[:path] = m[:path]
              @store[:query] = m[:query]
              @store[:fragment] = m[:fragment]
            }
          end
        end

        def netpath
          URIString.new(nil,authority,path,nil,nil).to_s
        end
        def netpath=(val)
          if !val
            self.authority = nil
            self.path = ""
          else
            Alt::URI::Parse::RE_GENERIC.match(val) { |m|
              self.authority = m[:authority]
              self.path = m[:path]
            }
          end
        end
        def to_s
          URIString.new(@store[:scheme],authority,@store[:path],@store[:query],@store[:fragment]).to_s
        end

        def absolute?
          self.scheme != nil
        end

        def relative?
          !self.absolute?
        end

        def abs(base)
          Alt::URI::Algorithm.transform(self,base)
        end

        def rel(base)
          Alt::URI::Algorithm.relative(self,base)
        end
        def inspect()
          str = @store.keys.map{ |k| "#{k}:#{@store[k].inspect}" }.join(" ")
          
          sprintf '#<URIParts:0x%0x %s>',self.object_id,str
        end

      end
    end
  end
end

