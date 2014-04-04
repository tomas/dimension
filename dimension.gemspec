# -*- encoding: utf-8 -*-
require File.expand_path("../lib/dimension/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "dimension"
  s.version     = Dagger::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Tomás Pollak']
  s.email       = ['tomas@forkhq.com']
  s.homepage    = "https://github.com/tomas/dimension"
  s.summary     = "Native, in-process image resizing in Ruby."
  s.description = "Yes, there are other graphic libraries besides ImageMagick."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "dimension"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
  # s.bindir       = 'bin'
end
