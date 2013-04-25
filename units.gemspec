# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "units"
  s.version     = '2'
  s.authors     = ["Brandon Fosdick"]
  s.email       = ["bfoz@bfoz.net"]
  s.homepage    = "http://github.com/bfoz/ruby-units"
  s.summary     = %q{Extends Numeric to add support for tracking units of measure}
  s.description = %q{Extends Numeric to add support for tracking units of measure}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
