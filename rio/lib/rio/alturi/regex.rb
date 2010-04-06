module Alt
  module URI
    module REGEXP
      module PATTERN

        ALPHA          =  "A-Z" + "a-z"
        DIGIT          =  "\\d"
        HEXDIG         =  DIGIT + "A" + "B" + "C" + "D" + "E" + "F"

      end

      module PATTERN
        # :stopdoc:

        UNRESERVED    = ALPHA + DIGIT + "." + "_" + "~" + "-"

        # gen-delims    = ":" / "/" / "?" / "#" / "[" / "]" / "@"
        GEN_DELIMS    = ":" + "/" + "?" + "#" + "[" + "]" + "@"

        # sub-delims    = "!" / "$" / "&" / "'" / "(" / ")"
        #           / "*" / "+" / "," / ";" / "="
        SUB_DELIMS    = "!" + "$" + "&" + "'" + "(" + ")" +
          "*" + "+" + "," + ";" + "="

        # reserved      = gen-delims / sub-delims
        RESERVED      = GEN_DELIMS + SUB_DELIMS

        # pct-encoded   = "%" HEXDIG HEXDIG
        PCT_ENCODED   = "%[#{HEXDIG}][#{HEXDIG}]"

        # userinfo    = *( unreserved / pct-encoded / sub-delims / ":" )
        UCHAR           = ":" + SUB_DELIMS + UNRESERVED

        # pchar         = unreserved / pct-encoded / sub-delims / ":" / "@"
        PCHAR           = ":" + "@" + SUB_DELIMS + UNRESERVED

        # query         = *( pchar / "/" / "?" )
        QCHAR           = "/" + "?" + PCHAR
        QPCHAR          = QCHAR.sub('&','')

        # fragment      = *( pchar / "/" / "?" )
        FCHAR           = "/" + "?" + PCHAR

        # :startdoc:
      end # PATTERN
      PCT_ENCODED = Regexp.new("#{PATTERN::PCT_ENCODED}")

      PCHAR = Regexp.new("[/#{PATTERN::PCHAR}]")
      QCHAR = Regexp.new("[#{PATTERN::QCHAR}]")
      QPCHAR = Regexp.new("[#{PATTERN::QPCHAR}]")
      FCHAR = Regexp.new("[#{PATTERN::FCHAR}]")
      UCHAR = Regexp.new("[#{PATTERN::UCHAR}]")
      # :startdoc:
    end # REGEXP
  end
end


if __FILE__ == $0
  # TODO Generated stub
end
