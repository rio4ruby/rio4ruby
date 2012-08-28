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

      #RE_PARTS = /^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/
    #   RE_GENERIC0 = %r{
    #  (?<scheme>      [^:/?#]+   ){0}
    #  (?<authority>   [^/?#]*    ){0}
    #  (?<path>        [^?#]*     ){0}
    #  (?<query>       [^#]*      ){0}
    #  (?<fragment>    .*         ){0}

    #  (      \g<scheme>     :   )?
    #  (  //  \g<authority>      )?
    #         \g<path>
    #  (  \?  \g<query>          )?
    #  (  \#  \g<fragment>       )?
    # }x
      RE_GENERIC = %r{
     (?:      (  [^:/?#]+  )  :  )?
     (?:  //  (  [^/?#]*   )     )?
              (  [^?#]*    )
     (?:  \?  (  [^#]*     )     )?
     (?:  \#  (  .*        )     )?
     }x

      #def self.parse(ustr)
      #  parse_re(ustr,RE_GENERIC)
      #end

      #authority   = [ userinfo "@" ] host [ ":" port ]
      #RE_AUTHORITY0 = %r{
      #(?<userinfo>      [^@]+   ){0}
      #(?<host>          [^:]*   ){0}
      #(?<port>          .*      ){0}
      #
      #(      \g<userinfo> @   )?
      #      \g<host>
      #(   :  \g<port>         )?
      #}x

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
