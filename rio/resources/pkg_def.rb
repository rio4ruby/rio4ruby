#--
# =========================================================================== 
# Copyright (c) 2005,2006,2007,2008,2009,2010 Christopher Kleckner
# All rights reserved
#
# This file is part of the Rio library for ruby.
#
# Rio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Rio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rio; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# ===========================================================================
#
#++

require 'rio/doc'

module PKG
  NAME = "rio"
  TITLE = RIO::TITLE
  VERSION = RIO::VERSION
  FULLNAME = PKG::NAME + "-" + PKG::VERSION
  SUMMARY = RIO::SUMMARY
  DESCRIPTION = RIO::DESCRIPTION
  AUTHOR = "Christopher Kleckner"
  EMAIL = "rio4ruby@rubyforge.org"
  RUBYFORGE_PROJECT = PKG::NAME
  HOMEPAGE = "http://#{PKG::RUBYFORGE_PROJECT}.rubyforge.org/"
  RUBYFORGE_URL = "http://rubyforge.org/projects/#{PKG::RUBYFORGE_PROJECT}"
  # RDOC_OPTIONS = ['--show-hash','--line-numbers','-mRIO::Doc::SYNOPSIS','-Tdoc/generators/template/html/rio.rb']
  RDOC_OPTIONS = ['--show-hash','-mRIO::Doc::SYNOPSIS','-Tparts']
  module FILES
    SRC = rio('lib').norecurse('.svn').files['*.rb']
    DOTDOC = rio('.').all.files['.document']
    DOC = rio['README'] + 
      rio('lib')['rio.rb'] + 
      rio('lib/rio/doc/')['*.rb'] +
      rio('lib/rio/if/')['*.rb'] + 
      rio('lib/rio')['kernel.rb','constructor.rb']
    XMP = rio('ex').entries[]
    TMPL = rio('rdoc').norecurse('.svn').all.files.skip.dirs['.svn']
    TST = rio('test').norecurse('.svn','qp').all.files('*.rb').skip.dirs['qp','.svn']
    MSC = rio.files['setup.rb', 'COPYING', 'Rakefile', 'ChangeLog', 'VERSION']
    
    [SRC,DOC,TMPL,XMP,TST,MSC,DOTDOC].each do |fary|
      fary.map! { |f| f.to_s }
    end
    DIST  =  SRC + DOC + TMPL + XMP + TST + MSC + DOTDOC
  end

  OUT_DIR = 'pkg'
  OUT_FILES = %w[.gem .tar.gz .zip].map { |ex| PKG::OUT_DIR + '/' + FULLNAME + ex }
end