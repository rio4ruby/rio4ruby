require 'rio'

def meth_str(str)
  nca = []
  ca = str
  str.each_byte do |el|
    nca << case el
           when 0x23
             '#method-i'
           else
             sprintf("%02X",el)
           end
  end
  nca.join('-')
end


devroot = rio(__FILE__).dirname.dirname
rio(devroot,'lib/rio/if').files('*.rb') do |file|
 
  contents = file.contents
  
  newcont = contents.gsub(/(IF::\w+(#([a-z_]+[a-z?=!]?)))/,'{\2}[rdoc-ref:\1]')

  newcont = newcont.gsub(/((IF::\w+)(#(\[\]|<<?|>>?|\|)))/) do |match|
    # puts "1: #{$1} 2: #{$2} 3: #{$3}"
    mth = $3
    link_str = 'RIO/' + $2.sub('::','/') + '.html'
    "{#{mth}}[link:#{link_str}#{meth_str(mth)}]"
  end

  if newcont != contents
    puts file
    rio(file) < newcont
  end
end
