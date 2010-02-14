require 'rio/alturi/regex'

module Alt
  module URI
    module Escape
      def self.build_escape_table(re)
        ca = []

        (0..255).each do |n|
          ca[n] = (n.chr =~ re ? n.chr : sprintf('%%%02X', n))
        end
        return ca
      end

      CHAR_TABLE = {
        :path =>      build_escape_table(REGEXP::PCHAR),
        :query =>     build_escape_table(REGEXP::QCHAR),
        :query_part =>     build_escape_table(REGEXP::QPCHAR),
        :fragment =>  build_escape_table(REGEXP::FCHAR),
        :userinfo =>  build_escape_table(REGEXP::UCHAR),
      }

      def escape(str,arg)
        Escape.escape(str,arg)
      end

      def self.escape(str,arg)
        tmp = ""
        table = (::Symbol === arg ? CHAR_TABLE[arg] : arg)
        str.each_byte do |b|
          tmp << table[b]
        end
        tmp.encode(str.encoding)
      end

      def self.build_unescape_hash
        lookup = {}

        chars = "0123456789ABCDEF"
        chars.split('').each do |cu|
          chars.split('').each do |cl|
            str = "%#{cu}#{cl}"
            lookup[str] = str[1,2].hex.chr
          end
        end
        lookup
      end
      UNESCAPE_HASH = build_unescape_hash

      def self.unescape(estr)
        ustr = ""
        pos = 0
        while npos = estr.index('%',pos)
          ustr << estr[pos,npos-pos] << UNESCAPE_HASH[estr[npos,3]]
          pos = npos +3
        end
        ustr << estr[pos..-1]
      end

      def unescape(str)
        Escape.unescape(str)
      end

      def self.unescape0(str, escaped = REGEXP::PCT_ENCODED)
        str.gsub(escaped) {
          [$&[1, 2].hex].pack('C')
        }.force_encoding(str.encoding)
      end
    end
  end
end

if __FILE__ == $0
  # TODO Generated stub
end
