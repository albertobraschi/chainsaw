# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{chainsaw}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ucnv"]
  s.autorequire = %q{}
  s.date = %q{2009-03-07}
  s.description = %q{A Ruby library for spidering web resources.}
  s.email = %q{ucnvvv at gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.files = ["README.rdoc", "ChangeLog", "Rakefile", "test/helper.rb", "test/htdocs", "test/htdocs/01.html", "test/htdocs/02.html", "test/htdocs/03.html", "test/htdocs/04.html", "test/htdocs/05.html", "test/htdocs/06.html", "test/htdocs/cgi.rb", "test/htdocs/img.gif", "test/server.rb", "test/test_browser.rb", "test/test_chainsaw.rb", "test/test_element.rb", "test/test_ext.rb", "test/test_m17n.rb", "lib/chainsaw", "lib/chainsaw/browser.rb", "lib/chainsaw/common.rb", "lib/chainsaw/element.rb", "lib/chainsaw/ext", "lib/chainsaw/ext/httpclient.rb", "lib/chainsaw/ext/nokogiri.rb", "lib/chainsaw.rb", "examples/01_google.rb", "examples/02_twitter.rb", "examples/03_delicious.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ucnv/chainsaw/tree/master}
  s.rdoc_options = ["--title", "chainsaw documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{chainsaw}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A Ruby library for spidering web resources.}
  s.test_files = ["test/test_browser.rb", "test/test_chainsaw.rb", "test/test_element.rb", "test/test_ext.rb", "test/test_m17n.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.2.1"])
      s.add_runtime_dependency(%q<httpclient>, [">= 2.1.4"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.2.1"])
      s.add_dependency(%q<httpclient>, [">= 2.1.4"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.2.1"])
    s.add_dependency(%q<httpclient>, [">= 2.1.4"])
  end
end
