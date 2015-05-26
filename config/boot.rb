require 'rubygems'

if defined? Encoding
  Encoding.default_external = Encoding.find("UTF-8")
  Encoding.default_internal = Encoding.find("UTF-8")
end

# Set up gems listed in the Gemfile.
gemfile = File.expand_path('../../Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)

require 'base64'
