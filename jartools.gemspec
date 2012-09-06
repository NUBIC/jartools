# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jartools/version"

Gem::Specification.new do |s|
  s.name        = "jartools"
  s.version     = JarTools::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rhett Sutphin"]
  s.email       = ["rhett@detailedbalance.net"]
  s.homepage    = "http://github.com/rsutphin/jartools"
  s.summary     = %q{A set of command line tools for looking through java archives (JARs and WARs)}
  s.description = %q{jartools provides a busybox of command-line tools
                     for examining the contents and metadata of java archive files (JARs and WARs).}

  s.files         = Dir["{lib,spec,bin}/**/*"] + Dir["*.md"] + %w(Rakefile Gemfile)
  s.test_files    = Dir["spec/**/*"]
  s.executables   = %w(jartools)
  s.require_paths = ["lib"]

  s.add_runtime_dependency "thor", "~> 0.14.0"
  s.add_runtime_dependency "rubyzip", "0.9.4"
  s.add_runtime_dependency "diff-lcs", "~> 1.1.2"
  s.add_development_dependency "rspec", "~> 2.3"
  s.add_development_dependency "ci_reporter", "~> 1.6"
  s.add_development_dependency "rake", "~> 0.9"
end
