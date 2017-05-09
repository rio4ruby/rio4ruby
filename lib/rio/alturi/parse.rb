module Alt
  module URI
    module Parse
      def self.set_named_match_fields(obj,m,re)
        re.names.each do |name|
          obj.__send__(name+'=',m[name])
        end
        obj
      end

      def self.parse_re(str,re,parts = nil)
        re.match(str) { |m|
          parts ||= Parts.new
          set_named_match_fields(parts,m,re)
        }
      end

      RE_GENERIC = %r{
     (?:      (  [^:/?#]+  )  :  )?
     (?:  //  (  [^/?#]*   )     )?
              (  [^?#]*    )
     (?:  \?  (  [^#]*     )     )?
     (?:  \#  (  .*        )     )?
     }x

      RE_AUTHORITY = %r{
     (?:      (  [^@]+  )   @   )?
              (  [^:]*  )
     (?:   :  (  .*     )       )?
     }x

      RE_USERINFO = %r{
     (?:      (  [^:]+  )       )?
     (?:   :  (  .*     )       )?
     }x

      def self.parse_authority(ustr)
        parse_re(ustr,RE_AUTHORITY)
      end
    end
  end
end

if __FILE__ == $0
  # TODO Generated stub
end
