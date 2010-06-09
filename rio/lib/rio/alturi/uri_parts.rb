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
      class Base
        def _do_esc(str,fld)
          if str
            str.encode('UTF-8')

            Alt::URI::Escape.escape(str.force_encoding('US-ASCII'),fld) 
            #Alt::URI::Escape.escape(str,fld) 
          end
        end
        def _do_unesc(str)
          if str
            ustr = Alt::URI::Escape.unescape(str)
            ustr.force_encoding('UTF-8')
            if @encoding
              begin
                ustr.encode(@encoding)
              rescue Encoding::UndefinedConversionError
                ustr
              end
            else
              ustr
            end
          end
        end
        def nil_or(val,dflt=nil,&block)
          return dflt unless val
          yield val
        end
      end
    end
  end
end

module Alt
  module URI
    module Gen
      class URIString < Base
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

        def path 
          (@authority && 
           @authority.empty? && 
           !@path.empty? && 
           !@path.start_with?("/") ? "/" : "") + @path
        end

        def query
          '?' + @query if @query
        end

        def fragment
          '#' + @fragment if @fragment
        end

        def to_s
          str = "#{scheme}#{authority}#{path}#{query}#{fragment}"
          #p "Alt::URI::Gen::URIString"
          #p str
          str
        end
      end
    end
  end
end


module Alt
  module URI
    module Gen
      class UserInfoParts < Base
        attr_reader :store
        def initialize
          @store = {}
        end
        def initialize_copy(other)
          super
          @store = other.store.dup
        end
        def self.parse(val)
          ui = new
          if val
            us,pw = val.split(':',2)
            ui.store[:user] = us
            ui.store[:password] = pw
          end
          ui
        end
        def ==(other)
          @store == other.store
        end
        def [](sym)
          @store[sym]
        end

        def []=(sym,val)
          @store[sym] = val
        end



        def user
          _do_unesc(@store[:user])
        end
        def user=(val)
          @store[:user] = nil_or(val) { |v| 
            _do_esc(v,:user) 
          }
        end
        def password=(val)
          @store[:password] = val
        end

        def password
           @store[:password]
        end
        def value
          self.to_s if @store[:user]
        end
        def to_s
          # RFC 3986 3.2.1
          # Use of the format "user:password" in the userinfo field is
          # deprecated.  Applications should not render as clear text any data
          # after the first colon (":") character found within a userinfo
          # subcomponent unless the data after the colon is the empty string
          # (indicating no password).
          u = @store[:user]
          passwd = ':' if @store[:password] and @store[:password].empty?
          "#{u}#{passwd}"
        end
      end

    end
  end
end

module Alt
  module URI
    module Gen
      class AuthParts < Base
        attr_reader :store
        def initialize
          @store = {}
        end
        def initialize_copy(other)
          super
          @store = other.store.dup
        end
        def self.parse(val)
          auth = new
          if val
            Alt::URI::Parse::RE_AUTHORITY.match(val) { |m|
              auth.store[:host] = m[2].downcase
              auth.store[:port] = m[3]
              auth.store[:userinfo] = UserInfoParts.parse(m[1])
            }
          end
          auth
        end
        def ==(other)
          @store == other.store
        end
        def [](sym)
          @store[sym]
        end

        def []=(sym,val)
          @store[sym] = val
        end

        def host=(val)
          @store[:host] = nil_or(val) { |v| v.downcase }
        end
        def host
          @store[:host] if @store[:host]
        end
        def user=(val)
          @store[:userinfo] ||= UserInfoParts.new
          @store[:userinfo].user = val
        end
        def user
          @store[:userinfo].user if @store[:userinfo]
        end
        def password=(val)
          @store[:userinfo] ||= UserInfoParts.new
          @store[:userinfo].password = val
        end
        def password
          @store[:userinfo].password if @store[:userinfo]
        end
#        def userinfo
#          _do_unesc(@store[:userinfo]) if @store[:userinfo]
#        end


        def userinfo
          @store[:userinfo].value if @store[:userinfo]
        end
        def userinfo=(val)
          @store[:userinfo] = UserInfoParts.parse(val) if val
        end


        def port
          @store[:port]
        end

        def port=(val)
          @store[:port] = val
        end
        def value
          self.to_s if self.host
        end
        def to_s
          ui = @store[:userinfo].value + '@' if @store[:userinfo] and @store[:userinfo].value
          hst = @store[:host]
          prt = ':' + @store[:port] if @store[:port]
          "#{ui}#{hst}#{prt}"
        end
      end

    end
  end
end
module Alt
  module URI
    module Gen
      class URIParts < Base
        attr_reader :store
        attr_accessor :encoding
        def initialize(opts={})
          @store = { :path => "" }
          @encoding = opts[:encoding]
          # p "@encoding=#{@encoding.inspect}"
          # p caller[0]
          # @encoding = @store[:path].encoding
          # p "URIParts",__ENCODING__
          # @encoding = Encoding.default_internal
          # @encoding = Encoding.find('UTF-8')
          # @encoding = __ENCODING__
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

        def self.parse(str,opts={})
          u = URIParts.new(opts)
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

#         def [](sym)
#           __send__(sym)
#         end

#         def []=(sym,val)
#           __send__(sym.to_s+'=',val)
#         end

        def [](sym)
          @store[sym]
        end

        def []=(sym,val)
          @store[sym] = val
        end

        def userinfo
          @store[:authority].userinfo if @store[:authority]
        end

        def userinfo=(val)
          @store[:authority] ||= AuthParts.new
          @store[:authority].userinfo = val
        end

        def user
          @store[:authority].user if @store[:authority]
        end

        def user=(val)
          @store[:authority] ||= AuthParts.new
          @store[:authority].user = val
        end

        def password
          @store[:authority].password if @store[:authority]
        end

        def password=(val)
          @store[:authority] ||= AuthParts.new
          @store[:authority].password = val
        end

        def authority
          #p @store
          @store[:authority].value if @store[:authority]
        end

        def authority=(val)
          @store[:authority] = AuthParts.parse(val) if val
        end

        def fragment=(val)
          @store[:fragment] = nil_or(val) { |v| _do_esc(v,:fragment) }
        end

        def scheme=(val)
          @store[:scheme] = nil_or(val) { |v| v.downcase }
        end
        def path=(val)
          @store[:path] = nil_or(val,"") { |v| 
            _do_esc(v,:path) 
          }
        end
        def path
          ans = _do_unesc(@store[:path])
          #p 'HERE'
          #p ans
          ans
        end


        def query=(val)
          @store[:query] = nil_or(val) { |v|
            if v.instance_of?(::Array)  
              unless v.empty?
                v.map { |el| 
                  _do_esc(el,:query_part) 
                }.join('&')
              end
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
        def port=(val)
          @store[:authority] ||= AuthParts.new
          @store[:authority].port = nil_or(val) { |v| v.to_s }
        end

        def host=(val)
          @store[:authority] ||= AuthParts.new
          @store[:authority].host = nil_or(val) { |v| v.downcase }
        end

        def scheme
          @store[:scheme]
        end

        def host
          @store[:authority].host if @store[:authority]
        end

        def port
          @store[:authority].port if @store[:authority]
        end


        def fragment
          _do_unesc(@store[:fragment]) if @store[:fragment]
        end

        def uri
          self.to_s
        end


        def uri=(val)
          if !val
            @store.clear
            @store[:path] = ""
          else
            #Alt::URI::Parse::RE_GENERIC.match(val) { |m|
            #  p "URI_PARTS: #{m.inspect}"
            #  self.scheme = m[:scheme]
            #  self.authority = m[:authority]
            #  @store[:path] = m[:path]
            #  @store[:query] = m[:query]
            #  @store[:fragment] = m[:fragment]
            #}
            Alt::URI::Parse::RE_GENERIC.match(val) { |m|
              #p "URI_PARTS: #{m.inspect}"
              self.scheme = m[1]
              self.authority = m[2]
              @store[:path] = m[3]
              @store[:query] = m[4]
              @store[:fragment] = m[5]
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
            #Alt::URI::Parse::RE_GENERIC.match(val) { |m|
            #  self.authority = m[:authority]
            #  self.path = m[:path]
            #}
            Alt::URI::Parse::RE_GENERIC.match(val) { |m|
              self.authority = m[2]
              self.path = m[3]
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

