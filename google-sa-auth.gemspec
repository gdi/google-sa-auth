# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "google-sa-auth"
  s.version     = "0.0.1"
  s.authors     = ["Jon Durbin"]
  s.email       = ["jond@greenviewdata.com"]
  s.homepage    = "https://github.com/gdi/google-sa-auth"
  s.summary     = %q{Simple gem for generating authorization tokens for google service accounts}
  s.description = %q{Simple gem for generating authorization tokens for google service accounts}

  s.rubyforge_project = "google-sa-auth"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rspec'
  s.add_dependency 'bundler'
  s.add_dependency 'curb-fu'
  s.add_dependency 'google-jwt'
  s.add_dependency 'json'
end
