# -*- encoding: utf-8 -*-
# stub: devise 1.1.9 ruby lib

Gem::Specification.new do |s|
  s.name = "devise"
  s.version = "1.1.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jos\u{c3}\u{a9} Valim", "Carlos Ant\u{c3}\u{b4}nio"]
  s.date = "2011-03-25"
  s.description = "Flexible authentication solution for Rails with Warden"
  s.email = "contact@plataformatec.com.br"
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "Gemfile.lock", "MIT-LICENSE", "README.rdoc", "TODO"]
  s.files = ["CHANGELOG.rdoc", "Gemfile.lock", "MIT-LICENSE", "README.rdoc", "TODO"]
  s.homepage = "http://github.com/plataformatec/devise"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.9"
  s.summary = "Flexible authentication solution for Rails with Warden"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<warden>, ["~> 1.0.2"])
      s.add_runtime_dependency(%q<bcrypt-ruby>, ["~> 2.1.2"])
    else
      s.add_dependency(%q<warden>, ["~> 1.0.2"])
      s.add_dependency(%q<bcrypt-ruby>, ["~> 2.1.2"])
    end
  else
    s.add_dependency(%q<warden>, ["~> 1.0.2"])
    s.add_dependency(%q<bcrypt-ruby>, ["~> 2.1.2"])
  end
end
