# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rio/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Christopher Kleckner"]
  gem.email         = ["rio4ruby@rio4ruby.com"]
  gem.description   = "Rio is a Ruby class wrapping much of the functionality of " +
                      "IO, File, Dir, Pathname, FileUtils, Tempfile, StringIO, " +
                      "OpenURI, Zlib, and CSV."

  gem.summary       = "Rio - Ruby I/O Facilitator"
  gem.homepage      = "http://rio4ruby.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rio"
  gem.require_paths = ["lib"]
  gem.version       = RIO::VERSION

  gem.add_dependency "test-unit"
end
