#
# = uri/http.rb
#
# Author:: Akira Yamada <akira@ruby-lang.org>
# License:: You can redistribute it and/or modify it under the same term as Ruby.
# Revision:: $Id$
#

require 'uri/generic'

module URI

  #
  # The syntax of HTTP URIs is defined in RFC1738 section 3.3.
  #
  # Note that the Ruby URI library allows HTTP URLs containing usernames and
  # passwords. This is not legal as per the RFC, but used to be 
  # supported in Internet Explorer 5 and 6, before the MS04-004 security 
  # update. See <URL:http://support.microsoft.com/kb/834489>.
  #
  class FILE < Generic
    include REGEXP
    #DEFAULT_PORT = 80

    COMPONENT = [
      :scheme, 
      :host, 
      :path, 
    ].freeze

    #
    # == Description
    #
    # Create a new URI::HTTP object from components, with syntax checking.
    #
    # The components accepted are userinfo, host, port, path, query and
    # fragment.
    #
    # The components should be provided either as an Array, or as a Hash 
    # with keys formed by preceding the component names with a colon. 
    #
    # If an Array is used, the components must be passed in the order
    # [userinfo, host, port, path, query, fragment].
    #
    # Example:
    #
    #     newuri = URI::HTTP.build({:host => 'www.example.com', 
    #       :path> => '/foo/bar'})
    #
    #     newuri = URI::HTTP.build([nil, "www.example.com", nil, "/path", 
    #       "query", 'fragment'])
    #
    # Currently, if passed userinfo components this method generates 
    # invalid HTTP URIs as per RFC 1738.
    #
    def self.build(args)
      tmp = Util::make_components_hash(self, args)
      return super(tmp)
    end
    
    RMAJOR,RMINOR,RTINY =  RUBY_VERSION.split('.')
    if RMAJOR == 1 and RMINOR < 9
      def check_host(v)
        return v unless v
        if @registry || @opaque
          raise InvalidURIError, 
                "can not set host with registry or opaque"
        elsif v != '' and HOST !~ v
          raise InvalidComponentError,
                "bad component(expected host component): #{v}"
        end
        
        return true
      end
    else
      def check_host(v)
        return v unless v
        if @registry || @opaque
          raise InvalidURIError, 
                "can not set host with registry or opaque"
          #      elsif v != '' and @parser.regexp[:HOST] !~ v
        elsif v != '' and HOST !~ v
          raise InvalidComponentError,
                "bad component(expected host component): #{v}"
        end
        
        return true
      end
    end
    def host=(v)
      check_host(v)
      set_host(v)
      v
    end
    private :check_host

    #
    # == Description
    #
    # Create a new URI::HTTP object from generic URI components as per
    # RFC 2396. No HTTP-specific syntax checking (as per RFC 1738) is 
    # performed.
    #
    # Arguments are +scheme+, +userinfo+, +host+, +port+, +registry+, +path+, 
    # +opaque+, +query+ and +fragment+, in that order.
    #
    # Example:
    #
    #     uri = URI::HTTP.new(['http', nil, "www.example.com", nil, "/path",
    #       "query", 'fragment'])
    #
    def initialize(*arg)
      super(*arg)
      self.host = '' if self.host.nil?
    end

    #
    # == Description
    #
    # Returns the full path for an HTTP request, as required by Net::HTTP::Get.
    #
    # If the URI contains a query, the full path is URI#path + '?' + URI#query.
    # Otherwise, the path is simply URI#path.
    #
#     def request_uri
#       r = path_query
#       if r[0] != ?/
#         r = '/' + r
#       end

#       r
#     end
  end

  @@schemes['FILE'] = FILE
end
