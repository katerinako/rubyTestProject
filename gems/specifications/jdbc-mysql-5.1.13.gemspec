# -*- encoding: utf-8 -*-
# stub: jdbc-mysql 5.1.13 ruby lib

Gem::Specification.new do |s|
  s.name = "jdbc-mysql"
  s.version = "5.1.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger, Ola Bini and JRuby contributors"]
  s.date = "2010-12-09"
  s.description = "Install this gem and require 'mysql' within JRuby to load the driver."
  s.email = "nick@nicksieger.com, ola.bini@gmail.com"
  s.extra_rdoc_files = ["Manifest.txt", "README.txt", "LICENSE.txt"]
  s.files = ["Manifest.txt", "README.txt", "LICENSE.txt"]
  s.homepage = "http://jruby-extras.rubyforge.org/ActiveRecord-JDBC"
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "jruby-extras"
  s.rubygems_version = "2.1.9"
  s.summary = "MySQL JDBC driver for Java and MySQL/ActiveRecord-JDBC."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
  end
end
