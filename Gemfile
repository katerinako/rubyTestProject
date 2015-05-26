source 'http://rubygems.org'
#source 'http://gems.rubyforge.org'

gem 'rails', '~> 3.0.0'
gem 'jquery-rails'
gem 'date_validator'
gem 'devise', '~> 1.1.5'
gem 'meta_where', '~> 1.0.4'
#gem 'meta_search'
gem 'kaminari', '~> 0.12.4'
gem 'declarative_authorization'
# gem 'write_xlsx'
# gem 'axlsx', :git => "https://github.com/randym/axlsx", :tag => "1.0.17"
gem 'rubyXL', '~> 3.3.8'
#gem 'nokogiri'
gem 'rubyzip', '>=1.0'
gem 'rack-cache', :require => 'rack/cache'
gem 'dragonfly', '~>0.9.12'
gem 'diff-lcs'
gem "bcrypt-ruby"

platforms :ruby do
  gem "mysql2"
end

platforms :jruby do
  gem 'activerecord-jdbcmysql-adapter'
  gem 'jruby-openssl'
  gem "warbler"
end

 group :development do
   gem 'ruby-debug', :platforms => [:ruby_18, :jruby]
   gem 'ruby-debug19', :platforms => :ruby_19
 end
