#
# = CSS2 RDoc HTML template
#
# This is a template for RDoc that uses XHTML 1.0 Transitional and dictates a
# bit more of the appearance of the output to cascading stylesheets than the
# default. It was designed for clean inline code display, and uses DHTMl to
# toggle the visbility of each method's source with each click on the '[source]'
# link.
#
# == Authors
#
# * Michael Granger <ged@FaerieMUD.org>
#
# Copyright (c) 2002, 2003 The FaerieMUD Consortium. Some rights reserved.
#
# This work is licensed under the Creative Commons Attribution License. To view
# a copy of this license, visit http://creativecommons.org/licenses/by/1.0/ or
# send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California
# 94305, USA.
#

# Modified by Christopher Kleckner
# Copyright (c) 2005,2006. Some rights reserved.
# Licensed under the same terms as the original.


# This is disgraceful -- a hack required to exert control over how rubygems builds
# documentation for Rio. My desire to have the command "gem install rio" build the
# docs correctly overrides my sense of propriety in this case. I apologize to anyone
# who should have to look at this ugliness. 
# Begin UGLY
module Generators #:nodoc: all
  #####################################################################
  #
  # Handle common markup tasks for the various Html classes
  #

  module MarkUp

    # Convert a string in markup format into HTML. We keep a cached
    # SimpleMarkup object lying around after the first time we're
    # called per object.

    def markup(str, remove_para=false)
      return '' unless str
      unless defined? @markup
        #p 'RIO MARKUP'
        @markup = SM::SimpleMarkup.new

        # class names, variable names, file names, or instance variables
#        @markup.add_special(/(
#                               \b([A-Z]\w*(::\w+)*[.\#]\w+)  #    A::B.meth
#                             | \b([A-Z]\w+(::\w+)*)       #    A::B..
#                             | \#\w+[!?=]?                #    #meth_name 
#                             | \b\w+([_\/\.]+\w+)+[!?=]?  #    meth_name
#                             )/x, 
#                            :CROSSREF)
        meth_name_re = '\w+[!?=]?|<{1,2}|>{1,2}|\[\]|\||\/|\+@?|={2,3}|=~'
        @markup.add_special(/(
                               \b([A-Z]\w*(::\w+)*[.\#](#{meth_name_re}))  #    A::B.meth
                             | \b([A-Z]\w+(::\w+)*)       #    A::B..
                             | \#(#{meth_name_re})                #    #meth_name 
                             | \b\w+([_\/\.]+\w+)+[!?=]?  #    meth_name
                             )/x, 
                            :CROSSREF)

        # external hyperlinks
        @markup.add_special(/((link:|https?:|mailto:|ftp:|www\.)\S+\w)/, :HYPERLINK)

        # and links of the form  <text>[<url>]
        @markup.add_special(/(((\{.*?\})|\b\S+?)\[\S+?\.\S+?\])/, :TIDYLINK)
#        @markup.add_special(/\b(\S+?\[\S+?\.\S+?\])/, :TIDYLINK)

      end
      unless defined? @html_formatter
        @html_formatter = HyperlinkHtml.new(self.path, self)
      end

      # Convert leading comment markers to spaces, but only
      # if all non-blank lines have them

      if str =~ /^(?>\s*)[^\#]/
        content = str
      else
        content = str.gsub(/^\s*(#+)/)  { $1.tr('#',' ') }
      end

      res = @markup.convert(content, @html_formatter)
      if remove_para
        res.sub!(/^<p>/, '')
        res.sub!(/<\/p>$/, '')
      end
      res
    end
  end
end
module Generators
  class HyperlinkHtml < SM::ToHtml
    def handle_special_CROSSREF(special)
      #p 'handle_special_CROSSREF'
      name = special.text
      if name[0,1] == '#'
        lookup = name[1..-1]
        name = lookup unless Options.instance.show_hash
      else
        lookup = name
      end

      if /([A-Z].*)[.\#](.*)/ =~ lookup
        container = $1
        method = $2
        ref = @context.find_symbol(container, method)
      else
        ref = @context.find_symbol(lookup)
      end

      if ref and ref.document_self
        name.sub!(/^(RIO::)?IF::.+\#/,'Rio#')
        name.sub!(/^#/,'Rio#')
        if %w[Rio Grande String].include?(name)
          name
        else
          "<a href=\"#{ref.as_href(@from_path)}\">#{name}</a>"
        end
      else
        name
      end
    end
  end
end
# End UGLY

module RDoc
  module Page

    FONTS = "Verdana,Arial,Helvetica,sans-serif"

STYLE = %{
body {
  font-family: Verdana,Arial,Helvetica,sans-serif;
  font-size:   90%;
  margin: 0;
  margin-left: 0px;
  padding: 0;
  background: white;
}

h1,h2,h3,h4 { margin: 0; color: #8b4726; background: transparent; }
h1 { font-size: 150%; }
h2 { font-size: 140%; }
h3 { font-size: 130%; }
h4 { font-size: 120%; }
h2,h3,h4 { margin-top: 1em; }

a { 
  background: transparent; 
  color: #8b4500;  
  text-decoration: none; 
}
a:hover { 
  color: #ffa500;
  background: #8b4500; 
}

/* Override the base stylesheet's Anchor inside a table cell */
td > a {
  background: transparent;
  color: #099;
  text-decoration: none;
}

small { 
  font-size: 0.7em;
}
/* and inside a section title */
.section-title > a {
  background: transparent;
  color: #8b4500; 
  text-decoration: none;
}

/* === Structural elements =================================== */

div#index {
  margin: 0;
  margin-left: 0px;
  padding: 0;
  font-size: 90%;
  background: #ffdead;
}


div#index a {
  margin-left: 0.7em;
}
div#index-entries a {
  background: transparent;
  margin-left: 0.7em;
  color: #8b4500; 
}
div#index-entries a:hover {
  background: transparent;
  margin-left: 0.7em;
  /*   color: #ffdead;  */
  color: #ffdead; 
  background: #8b4500; 
  /*background: #ffdead;*/
}
.name-list a {
  margin-left: 0.7em;
  background: #ffdead; 
  color: #8b4500; 
}
.name-list a:hover {
  margin-left: 0.7em;
  color: #ffdead; 
  background: #8b4500; 
}
.section-bar {
  color: #555;
  /*   background: #8b4500; */
  
  border-bottom: 1px solid #999;
  margin-left: 0px;
}

div#index .section-bar {
  margin-left: 0px;
  padding-left: 0.7em;
  background: #8b4500; 
  color: #ffdead;
  font-size: small;
}


.section-title {
  /*background: #8b4500; */
  background: #ffdead;
  color: #eee;
  padding: 3px;
  margin-top: 2em;
  margin-left: 0px;
  border: 1px solid #999;
}

div#classHeader, div#fileHeader {
  width: auto;
  color: white;
  padding: 0.5em 1.5em 0.5em 1.5em;
  margin: 0;
  margin-left: 0px;
  border-bottom: 3px solid #006;
}

div#classHeader a, div#fileHeader a {
  background: inherit;
  color: white;
}

div#classHeader td, div#fileHeader td {
  background: inherit;
  color: white;
}


div#fileHeader {
  background: #8b4500; 

}
#fileHeader h1,#fileHeader h2,#fileHeader h3,#fileHeader h4 { 
  margin: 0; 
  color: #ffdead;
}

div#classHeader {
  background: #8b4500; 
}
td.class-header-space-col {
  width: 2em;
}


.class-mod {
  font-size:  110%;
  font-weight: bold;
  font-family: monospace;
  text-transform: lowercase;
  text-align: bottom;
             
}
.class-name-in-header {
  font-size:  150%;
  font-weight: bold;
  font-family: monospace;
}
.in-url { 
  font-size: 80%
}

div#bodyContent {
    padding: 0 1.5em 0 1.5em;
}


div#description {
    padding: 0.5em 1.5em;
    /* background: #efefef; */
    background: #ffdead;
    border: 1px dotted #999;
}

div#description h1,h2,h3,h4,h5,h6 {
    color: #8b4500;
    background: transparent;
}

div#validator-badges {
    text-align: center;
}
div#validator-badges img { border: 0; }

div#copyright {
    color: #333;
    background: #efefef;
    font: 0.75em sans-serif;
    margin-top: 5em;
    margin-bottom: 0;
    padding: 0.5em 2em;
}


/* === Classes =================================== */

table.header-table {
    color: white;
    font-size: small;
}

.type-note {
    font-size: small;
    color: #DEDEDE;
}

.xxsection-bar {
    background: #eee;
    color: #333;
    padding: 3px;
}



.section-title {
    background: #79a;
    color: #eee;
    padding: 3px;
    margin-top: 2em;
    margin-left: 0px;
    border: 1px solid #999;
}

.top-aligned-row {  vertical-align: top }
.bottom-aligned-row { vertical-align: bottom }

span.include-name {
  font-size: small;  
}
.include-name a {
  font-weight: bold;
}
ul.includes-ul {
  list-style-type: none;
  padding-left: 1em;
}


/* --- Context section classes ----------------------- */

.context-row { }
.context-item-name { font-family: monospace; font-weight: bold; color: black; }
.context-item-value { font-size: small; color: #448; }
.context-item-desc { color: #333; padding-left: 2em; }

/* --- Method classes -------------------------- */
.method-detail {
    background: #ffdead;
    padding: 0;
    margin-top: 0.5em;
    margin-bottom: 1em;
    border: 1px dotted #ccc;
}
.method-heading {
  font-family: monospace; 
  font-weight: bold;
  font-size: 130%;
  color: #191970;
  /* background: #b0c4de; */
  background: #ffa07a;
  border-bottom: 1px solid #666;
  padding: 0.2em 0.5em 0 0.5em;
}
.method-heading a {
   text-decoration: none;
}
.method-heading a:hover {
   text-decoration: underline;
  background: inherit;
  color: inherit;
}
.method-signature { color: black; background: inherit; }
.method-name { font-weight: bold; }
.method-args { font-style: italic; }

.method-description { padding: 0 0.5em 0 0.5em; }
pre.method-description 
{ 
  padding: 0 0.5em 0 0.5em; 
  color: #ee2222;
                    
}
#description pre
{ 
  padding: 0.2em 0 0.2em 0; 
  margin: 0.3em 0 0.3em 0;  
  background: #fff8dc;
  border-left: 2px solid #8b6508; 
  /* border-bottom: 1px solid #8b6508; */
  /*  border-top: 1px solid #8b6508; */
}
#description h1 { 
   color: #8b4500; 
  margin: 0.5em 0 0.2em 0;
  /*border: 1px solid red;*/
  }
#description h2 { 
   color: #8b4500; 
  margin: 0.5em 0 0.2em 0;
  /*border: 1px solid red;*/
  }
#description h3 { 
   color: #8b4500; 
  margin: 0.5em 0 0.2em 0;
  /*border: 1px solid red;*/
  }
#description h4 { 
   color: #8b4500; 
  margin: 0.5em 0 0.2em 0;
  /*border: 1px solid red;*/
  }
#description p { 
  margin: 0.5em 0 0.2em 0;
  /*border: 1px solid red;*/
  }
#description ul { 
  margin: 0.2em 0 0.5em 0;
  /* border: 1px solid red; */
  }
#description a { 
    background: #ffdead;
                 /* background: #eef; */
    color: #8b4500; 
    text-decoration: none; 
}
#description a:hover {     text-decoration: underline;  }
.method-description a { 
    background: #ffdead;
                 /* background: #eef; */
    color: #8b4500; 
    text-decoration: none; 
}
.method-description a:hover {     text-decoration: underline;  }

.method-description pre
{ 
  padding: 0.2em 0 0.2em 0; 
  margin: 0.3em 0 0.3em 0;  
  background: #fff8dc;
  border-left: 2px solid #8b6508; 
}

.method-description table
{ 
  border-top: 1px solid brown; 
  border-bottom: 1px solid brown; 
  margin: 0.4em 2em 0.4em 2em;
}
.method-description li
{ 
  padding: 0 0 0 0; 
  margin: 0 0 0 0; 
                    
}
.method-description p { 
  margin: 0.5em 0 0.2em 0;
  /* border: 1px solid red; */
  }
.method-description tt { 
  margin: 0.5em 0 0.2em 0;
  font-weight: bold;                     
  color: navy;                       
  }
.method-description ul { 
  margin: 0.2em 0 0.5em 0;
  /* border: 1px solid red; */
  }


/* --- Source code sections -------------------- */

a.source-toggle { font-size: 90%; }
div.method-source-code {
    background: #262626;
    color: #ffdead;
    margin: 1em;
    padding: 0.5em;
    border: 1px dashed #999;
    overflow: hidden;
}

div.method-source-code pre { color: #ffdead; overflow: hidden; }

/* --- Ruby keyword styles --------------------- */

.standalone-code { background: #221111; color: #ffdead; overflow: hidden; }

.ruby-constant  { color: #7fffd4; background: transparent; }
.ruby-keyword { color: #00ffff; background: transparent; }
.ruby-ivar    { color: #eedd82; background: transparent; }
.ruby-operator  { color: #00ffee; background: transparent; }
.ruby-identifier { color: #ffdead; background: transparent; }
.ruby-node    { color: #ffa07a; background: transparent; }
.ruby-comment { color: #b22222; font-weight: bold; background: transparent; }
.ruby-regexp  { color: #ffa07a; background: transparent; }
.ruby-value   { color: #7fffd4; background: transparent; }
}


#####################################################################
### H E A D E R   T E M P L A T E  
#####################################################################

XHTML_PREAMBLE = %{<?xml version="1.0" encoding="%charset%"?>
<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
}

HEADER = XHTML_PREAMBLE + %{
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
  <meta http-equiv="Content-Script-Type" content="text/javascript" />
  <link rel="stylesheet" href="%style_url%" type="text/css" media="screen" />
  <script type="text/javascript">
  // <![CDATA[

  function popupCode( url ) {
    window.open(url, "Code", "resizable=yes,scrollbars=yes,toolbar=no,status=no,height=150,width=400")
  }

  function toggleCode( id ) {
    if ( document.getElementById )
      elem = document.getElementById( id );
    else if ( document.all )
      elem = eval( "document.all." + id );
    else
      return false;

    elemStyle = elem.style;
    
    if ( elemStyle.display != "block" ) {
      elemStyle.display = "block"
    } else {
      elemStyle.display = "none"
    }

    return true;
  }
  
  // Make codeblocks hidden by default
  document.writeln( "<style type=\\"text/css\\">div.method-source-code { display: none }</style>" )
  
  // ]]>
  </script>

</head>
<body>
}


#####################################################################
### C O N T E X T   C O N T E N T   T E M P L A T E
#####################################################################

CONTEXT_CONTENT = %{
}


#####################################################################
### F O O T E R   T E M P L A T E
#####################################################################
FOOTER = %{
<div id="validator-badges">
   <p><small>Copyright &copy; 2005, 2006 Christopher Kleckner.  <a href="http://www.gnu.org/licenses/gpl.html">All rights reserved</a>.</small></p>
</div>

</body>
</html>
}


#####################################################################
### F I L E   P A G E   H E A D E R   T E M P L A T E
#####################################################################

FILE_PAGE = %{
  <div id="fileHeader">
    <h1>%short_name%</h1>
    <table class="header-table">
    <tr class="top-aligned-row">
      <td><strong>Path:</strong></td>
      <td>%full_path%
IF:cvsurl
        &nbsp;(<a href="%cvsurl%">CVS</a>)
ENDIF:cvsurl
      </td>
    </tr>
    <tr class="top-aligned-row">
      <td><strong>Last Update:</strong></td>
      <td>%dtm_modified%</td>
    </tr>
    </table>
  </div>
}


#####################################################################
### C L A S S   P A G E   H E A D E R   T E M P L A T E
#####################################################################

CLASS_PAGE = %{
    <div id="classHeader">
        <table class="header-table">
        <tr class="top-aligned-row">
          <td class="class-mod"><strong>%classmod%</strong></td>
          <td class="class-name-in-header">%full_name%</td>
            <td rowspan="2" class="class-header-space-col"></td>
            <td rowspan="2">
START:infiles
IF:full_path_url
                <a class="in-url" href="%full_path_url%">
ENDIF:full_path_url
                %full_path%
IF:full_path_url
                </a>
ENDIF:full_path_url
IF:cvsurl
        &nbsp;(<a href="%cvsurl%">CVS</a>)
ENDIF:cvsurl
        &nbsp;&nbsp;
END:infiles
            </td>
        </tr>

IF:parent
        <tr class="top-aligned-row">
            <td><strong>Parent:</strong></td>
            <td>
IF:par_url
                <a href="%par_url%">
ENDIF:par_url
                %parent%
IF:par_url
               </a>
ENDIF:par_url
            </td>
        </tr>
ENDIF:parent
        </table>
    </div>
}


#####################################################################
### M E T H O D   L I S T   T E M P L A T E
#####################################################################

METHOD_LIST = %{

  <div id="contextContent">
IF:diagram
    <div id="diagram">
      %diagram%
    </div>
ENDIF:diagram

IF:description
    <div id="description">
      %description%
    </div>
ENDIF:description

IF:requires
    <div id="requires-list">
      <h3 class="section-bar">Required files</h3>

      <div class="name-list">
START:requires
      HREF:aref:name:&nbsp;&nbsp;
END:requires
      </div>
    </div>
ENDIF:requires

IF:toc
    <div id="contents-list">
      <h3 class="section-bar">Contents</h3>
      <ul>
START:toc
      <li><a href="#%href%">%secname%</a></li>
END:toc
     </ul>
ENDIF:toc
   </div>

IF:methods
    <div id="method-list">
      <h3 class="section-bar">Methods</h3>

      <div class="name-list">
START:methods
      HREF:aref:name:&nbsp;&nbsp;
END:methods
      </div>
    </div>
ENDIF:methods



    <!-- if includes -->
IF:includes
    <div id="includes">
      <h3 class="section-bar">Included Modules</h3>

      <div id="includes-list">
        <ul class="includes-ul">
START:includes
          <li class="include-li">
            <span class="include-name">HREF:aref:name:</span>
          </li>
END:includes
        </ul>
      </div>
    </div>
ENDIF:includes

START:sections
    <div id="section">
IF:sectitle
      <h2 class="section-title"><a name="%secsequence%">%sectitle%</a></h2>
IF:seccomment
      <div class="section-comment">
        %seccomment%
      </div>      
ENDIF:seccomment
ENDIF:sectitle

IF:classlist
    <div id="class-list">
      <h3 class="section-bar">Classes and Modules</h3>

      %classlist%
    </div>
ENDIF:classlist

IF:constants
    <div id="constants-list">
      <h3 class="section-bar">Constants</h3>

      <div class="name-list">
        <table summary="Constants">
START:constants
        <tr class="top-aligned-row context-row">
          <td class="context-item-name">%name%</td>
          <td>=</td>
          <td class="context-item-value">%value%</td>
IF:desc
          <td width="3em">&nbsp;</td>
          <td class="context-item-desc">%desc%</td>
ENDIF:desc
        </tr>
END:constants
        </table>
      </div>
    </div>
ENDIF:constants

IF:aliases
    <div id="aliases-list">
      <h3 class="section-bar">External Aliases</h3>

      <div class="name-list">
                        <table summary="aliases">
START:aliases
        <tr class="top-aligned-row context-row">
          <td class="context-item-name">%old_name%</td>
          <td>-></td>
          <td class="context-item-value">%new_name%</td>
        </tr>
IF:desc
      <tr class="top-aligned-row context-row">
        <td>&nbsp;</td>
        <td colspan="2" class="context-item-desc">%desc%</td>
      </tr>
ENDIF:desc
END:aliases
                        </table>
      </div>
    </div>
ENDIF:aliases


IF:attributes
    <div id="attribute-list">
      <h3 class="section-bar">Attributes</h3>

      <div class="name-list">
        <table>
START:attributes
        <tr class="top-aligned-row context-row">
          <td class="context-item-name">%name%</td>
IF:rw
          <td class="context-item-value">&nbsp;[%rw%]&nbsp;</td>
ENDIF:rw
IFNOT:rw
          <td class="context-item-value">&nbsp;&nbsp;</td>
ENDIF:rw
          <td class="context-item-desc">%a_desc%</td>
        </tr>
END:attributes
        </table>
      </div>
    </div>
ENDIF:attributes
      


    <!-- if method_list -->
IF:method_list
    <div id="methods">
START:method_list
IF:methods
      <h3 class="section-bar">%type% %category% methods</h3>

START:methods
      <div id="method-%aref%" class="method-detail">
        <a name="%aref%"></a>

        <div class="method-heading">
IF:codeurl
          <a href="%codeurl%" target="Code" class="method-signature"
            onclick="popupCode('%codeurl%');return false;">
ENDIF:codeurl
IF:sourcecode
          <a href="#%aref%" class="method-signature">
ENDIF:sourcecode
IF:callseq
          <span class="method-name">%callseq%</span>
ENDIF:callseq
IFNOT:callseq
          <span class="method-name">%name%</span><span class="method-args">%params%</span>
ENDIF:callseq
IF:codeurl
          </a>
ENDIF:codeurl
IF:sourcecode
          </a>
ENDIF:sourcecode
        </div>
      
        <div class="method-description">
IF:m_desc
          %m_desc%
ENDIF:m_desc
IF:sourcecode
          <p><a class="source-toggle" href="#"
            onclick="toggleCode('%aref%-source');return false;">[Source]</a></p>
          <div class="method-source-code" id="%aref%-source">
<pre>
%sourcecode%
</pre>
          </div>
ENDIF:sourcecode
        </div>
      </div>

END:methods
ENDIF:methods
END:method_list

    </div>
ENDIF:method_list
END:sections
</div>
}
#def mlist(*args)
  #p(args)
#  METHOD_LIST0
#end
#module_function :mlist
#METHOD_LIST = mlist()

#####################################################################
### B O D Y   T E M P L A T E
#####################################################################

BODY = HEADER + %{

!INCLUDE!  <!-- banner header -->

  <div id="bodyContent">

} +  METHOD_LIST + %{

  </div>

} + FOOTER



#####################################################################
### S O U R C E   C O D E   T E M P L A T E
#####################################################################

SRC_PAGE = XHTML_PREAMBLE + %{
<html>
<head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
  <link rel="stylesheet" href="%style_url%" type="text/css" media="screen" />
</head>
<body class="standalone-code">
  <pre>%code%</pre>
</body>
</html>
}


#####################################################################
### I N D E X   F I L E   T E M P L A T E S
#####################################################################

FR_INDEX_BODY = %{
!INCLUDE!
}

FILE_INDEX = XHTML_PREAMBLE + %{
<!--

    %list_title%

  -->
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>%list_title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
  <link rel="stylesheet" href="%style_url%" type="text/css" />
  <base target="docwin" />
</head>
<body>
<div id="index">
  <h1 class="section-bar">%list_title%</h1>
  <div id="index-entries">
START:entries
    <a href="%href%">%name%</a><br />
END:entries
  </div>
</div>
</body>
</html>
}

CLASS_INDEX = FILE_INDEX
METHOD_INDEX = FILE_INDEX

INDEX = %{<?xml version="1.0" encoding="%charset%"?>
<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">

<!--

    %title%

  -->
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
</head>
<frameset rows="20%, 80%">
    <frameset cols="25%,35%,45%">
        <frame src="fr_file_index.html"   title="Files" name="Files" />
        <frame src="fr_class_index.html"  name="Classes" />
        <frame src="fr_method_index.html" name="Methods" />
    </frameset>
    <frame src="%initial_page%" name="docwin" />
</frameset>
</html>
}



  end # module Page
end # class RDoc

require 'rdoc/generators/template/html/one_page_html'
