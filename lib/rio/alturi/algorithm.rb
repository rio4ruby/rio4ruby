module Alt
  module URI
    module Algorithm
      
      def self.relative(t,base)
        r = t.class.new
        if t.scheme != base.scheme
          r = t
        else
          if t.authority != base.authority
            r = t
          else
            r.path = rel_path(t.path,base.path)
            r.path = "." if r.path.empty?
            r.query = t.query
            r.fragment = t.fragment
          end
        end
        return r 
      end 
      
      def self.rel_path(path,base)
        bs = base.split("/",-1)
        pa = path.split("/",-1)
        bsize = bs.size
        psize = pa.size
        out = []
        (0...[bsize,psize].min).each do |i|
          out[0] = pa[i]
          if bs[i] != pa[i]
            i += 1
            out.unshift(*([".."] * (bsize - i)))
            out += pa[i,psize-1]
            return out.join("/")
          end
        end
        if bsize > psize
          out.unshift(*([".."] * (bsize - psize)))
        elsif psize > bsize
          out += pa[bsize,psize-bsize]
        end
        return out.join("/")
      end

      # 7) The resulting URI components, including any inherited from the
      #     base URI, are recombined to give the absolute form of the URI
      #     reference.  Using pseudocode, this would be

      #        result = ""

      #        if scheme is defined then
      #            append scheme to result
      #            append ":" to result

      #        if authority is defined then
      #            append "//" to result
      #            append authority to result

      #        append path to result

      #        if query is defined then
      #            append "?" to result
      #            append query to result

      #        if fragment is defined then
      #            append "#" to result
      #            append fragment to result

      #        return result

      def self.uri_string(r)
        ( defined(r.scheme) ? r.scheme + ":"  : "") + 
          ( defined(r.authority) ? "//" + r.authority : "") + 
          r.path +
          ( defined(r.query) ? "?" + r.query : "") +
          ( defined(r.fragment) ? "#" + r.fragment : "") 
      end

      def self.authority_string(r)
        ( defined(r.userinfo) ? r.userinfo + "@"  : "") + 
          r.host +
          ( defined(r.port) ? ":" + r.port : "") 
      end

      def self.defined(el)
        !el.nil?
      end

      def self.transform(r,base,strict=true)

        #-- A non-strict parser may ignore a scheme in the reference
        #-- if it is identical to the base URI's scheme.
        #--
        if ((not strict) and (r.scheme == base.scheme))
          r.scheme = nil
        end

        t = r.class.new
        if defined(r.scheme) 
          t.scheme    = r.scheme;
          t.authority = r.authority;
          t.path      = remove_dot_segments(r.path);
          t.query     = r.query;
        else
          if defined(r.authority) 
            t.authority = r.authority;
            t.path      = remove_dot_segments(r.path);
            t.query     = r.query;
          else
            if (r.path == "") 
              t.path = base.path;
              
              if defined(r.query)
                t.query = r.query;
              else
                t.query = base.query;
              end
            else
              if (r.path.start_with?("/")) then
                t.path = remove_dot_segments(r.path);
              else
                t.path = merge(base, r);
                t.path = remove_dot_segments(t.path);
              end
              t.query = r.query;
            end
            t.authority = base.authority;
          end
          t.scheme = base.scheme;
        end
        t.fragment = r.fragment;

        return t
      end   


      # 5.2.3.  Merge Paths

      #    The pseudocode above refers to a "merge" routine for merging a
      #    relative-path reference with the path of the base URI.  This is
      #    accomplished as follows:

      #    o  If the base URI has a defined authority component and an empty
      #       path, then return a string consisting of "/" concatenated with the
      #       reference's path; otherwise,



      #    o  return a string consisting of the reference's path component
      #       appended to all but the last segment of the base URI's path (i.e.,
      #       excluding any characters after the right-most "/" in the base URI
      #       path, or excluding the entire base URI path if it does not contain
      #       any "/" characters).


      def self.merge(base,r)
        if defined(base.authority) and base.path.empty?
          "/"
        else
          if npos = base.path.rindex("/")
            base.path[0,npos+1]
          else
            ""
          end
        end + r.path
      end


      # 5.2.4.  Remove Dot Segments

      #    The pseudocode also refers to a "remove_dot_segments" routine for
      #    interpreting and removing the special "." and ".." complete path
      #    segments from a referenced path.  This is done after the path is
      #    extracted from a reference, whether or not the path was relative, in
      #    order to remove any invalid or extraneous dot-segments prior to
      #    forming the target URI.  Although there are many ways to accomplish
      #    this removal process, we describe a simple method using two string
      #    buffers.

      #    1.  The input buffer is initialized with the now-appended path
      #        components and the output buffer is initialized to the empty
      #        string.

      #    2.  While the input buffer is not empty, loop as follows:

      #        A.  If the input buffer begins with a prefix of "../" or "./",
      #            then remove that prefix from the input buffer; otherwise,

      #        B.  if the input buffer begins with a prefix of "/./" or "/.",
      #            where "." is a complete path segment, then replace that
      #            prefix with "/" in the input buffer; otherwise,

      #        C.  if the input buffer begins with a prefix of "/../" or "/..",
      #            where ".." is a complete path segment, then replace that
      #            prefix with "/" in the input buffer and remove the last
      #            segment and its preceding "/" (if any) from the output
      #            buffer; otherwise,

      #        D.  if the input buffer consists only of "." or "..", then remove
      #            that from the input buffer; otherwise,

      #        E.  move the first path segment in the input buffer to the end of
      #            the output buffer, including the initial "/" character (if
      #            any) and any subsequent characters up to, but not including,
      #            the next "/" character or the end of the input buffer.

      #    3.  Finally, the output buffer is returned as the result of
      #        remove_dot_segments.

      def self.remove_dot_segments(instr)
        #    1.  The input buffer is initialized with the now-appended path
        #        components and the output buffer is initialized to the empty
        #        string.
        inp = instr.dup
        out = ""

        #    2.  While the input buffer is not empty, loop as follows:
        while !inp.empty?

          #        A.  If the input buffer begins with a prefix of "../" or "./",
          #            then remove that prefix from the input buffer; otherwise,
          unless inp.sub!( %r'^\.\.?/' , '')

            #        B.  if the input buffer begins with a prefix of "/./" or "/.",
            #            where "." is a complete path segment, then replace that
            #            prefix with "/" in the input buffer; otherwise,
            unless inp.sub!( %r'^/\.(/|\Z)' ,"/" )#

              #        C.  if the input buffer begins with a prefix of "/../" or "/..",
              #            where ".." is a complete path segment, then replace that
              #            prefix with "/" in the input buffer and remove the last
              #            segment and its preceding "/" (if any) from the output
              #            buffer; otherwise,
              if inp.sub!( %r'^/\.\.(/|\Z)' ,"/" )
                out.sub!(%r'/?[^/]*\Z',"")
              else

                #        D.  if the input buffer consists only of "." or "..", then remove
                #            that from the input buffer; otherwise,
                unless inp.sub!( /^\.\.?$/, "")

                  #        E.  move the first path segment in the input buffer to the end of
                  #            the output buffer, including the initial "/" character (if
                  #            any) and any subsequent characters up to, but not including,
                  #            the next "/" character or the end of the input buffer.
                  inp.sub!( %r'^(/?[^/]*)' ) { |match|
                    out << match
                    ""
                  }
                  
                end
              end
            end
          end
        end

        #    3.  Finally, the output buffer is returned as the result of
        #        remove_dot_segments.
        out

      end


      def self.dump_bufs(inp,out)
        #printf("inp:[%-15s]  out:[%-15s]\n",inp,out)
      end

      def self.remove_dot_segments0(inp)
        out = ""
        while !inp.empty?
          unless inp.sub!( %r'^\.\.?/' , "")
            unless inp.sub!( %r'^/\.(/|\Z)' ,"/" )
              if inp.sub!( %r'^/\.\.(/|\Z)' ,"/" )
                out.sub!(%r'/?[^/]*\Z',"")
              else
                unless inp.sub!( /^\.\.?$/, "")
                  inp.sub!( %r'^(/?[^/]*)' ) { |match|
                    out << match
                    ""
                  }
                  
                end
              end
            end
          end
        end
        out
      end

    end


  end
end


