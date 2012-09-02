require 'rio'

devroot = rio(__FILE__).dirname.dirname
devroot.all.files('INTRO.rb') do |file|
  puts file
  newlines = []
  file.lines do |line|
    unless line =~ /^#/
      newlines << line
      next
    end
    unless line =~ /^#/ && line =~ /IF::/
      newlines << line
      next
    end
    newlines << line.gsub(/(IF::\w+(#(([a-z]+[a-z?=!]?)|[\/\|\+\-]|>>?|<<?|\[\])))/,'{\2}[rdoc-ref:\1]')
  end
  rio(file) < newlines

end
