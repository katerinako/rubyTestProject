# -*- encoding: utf-8 -*-
# stub: activerecord-jdbcmysql-adapter 1.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "activerecord-jdbcmysql-adapter"
  s.version = "1.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger, Ola Bini and JRuby contributors"]
  s.date = "2012-01-28"
  s.description = "Install this gem to use MySQL with JRuby on Rails."
  s.email = "nick@nicksieger.com, ola.bini@gmail.com"
  s.homepage = "https://github.com/jruby/activerecord-jdbc-adapter"
  s.require_paths = ["lib"]
  s.rubyforge_project = "jruby-extras"
  s.rubygems_version = "2.1.9"
  s.summary = "MySQL JDBC adapter for JRuby on Rails."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord-jdbc-adapter>, ["~> 1.2.2"])
      s.add_runtime_dependency(%q<jdbc-mysql>, ["~> 5.1.0"])
    else
      s.add_dependency(%q<activerecord-jdbc-adapter>, ["~> 1.2.2"])
      s.add_dependency(%q<jdbc-mysql>, ["~> 5.1.0"])
    end
  else
    s.add_dependency(%q<activerecord-jdbc-adapter>, ["~> 1.2.2"])
    s.add_dependency(%q<jdbc-mysql>, ["~> 5.1.0"])
  end
end
