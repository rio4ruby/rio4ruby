require 'rio'

devroot = rio(__FILE__).dirname.dirname
devroot.all.files('*.rb') do |file|
  newlines = []
  chcnt = 0
  file.lines do |line|
    unless line =~ /^#/
      newlines << line
      next
    end
    unless line =~ /^#/ && line =~ /IF::/
      newlines << line
      next
    end
    re = /(IF::\w+(#(([a-z]+[a-z?=!]?)|[\/\|\+\-]|>>?|<<?|\[\])))/
    if re =~ line
      newlines << line.gsub(re,'{\2}[rdoc-ref:\1]')
      chcnt += 1
    end
  end

  if chcnt > 0
    puts file
    rio(file) < newlines
  end

end
