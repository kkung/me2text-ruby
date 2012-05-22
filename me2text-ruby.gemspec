# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "me2text/version"

Gem::Specification.new do |s|
  s.name        = "me2text-ruby"
  s.version     = Me2Text::VERSION
  s.authors     = ["codian"]
  s.email       = ["codian@gmail.com"]
  s.homepage    = "https://github.com/me2day/me2text-ruby"
  s.summary     = %q{me2text parser for ruby}
  s.description = %q{me2text is text format for me2day posting.
me2text-ruby is ruby library to convert me2text to HTML or plain text}
  s.rubyforge_project = "me2text-ruby"
  s.files         = Dir['{lib/**/*,test/**/*}'] +
                      %w(.gitignore me2text-ruby.gemspec Gemfile MIT-LICENSE Rakefile README.rdoc)
  s.test_files    = Dir['test/**/*_test.rb']
  s.executables   = ''
  s.require_paths = ["lib"]

  s.extra_rdoc_files = ['MIT-LICENSE', 'README.rdoc']
  s.rdoc_options = ["--main", "README.rdoc", "-c", "UTF-8"]


  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
