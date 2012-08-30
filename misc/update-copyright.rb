require 'rio'

old_cr = 'Copyright (c) 2005,2006,2007,2008,2009,2010 Christopher Kleckner'
new_cr = 'Copyright (c) 2005-2012 Christopher Kleckner'

old_cr_re = Regexp.new(Regexp.escape(old_cr))

devroot = rio(__FILE__).dirname.dirname
devroot.all.files('*.rb') do |file|
  next if file.to_s == __FILE__
  contents = file.contents
  if old_cr_re =~ contents
    puts file
    rio(file) < contents.sub(old_cr_re,new_cr)
  end

end
