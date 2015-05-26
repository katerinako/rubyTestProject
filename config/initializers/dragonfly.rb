require 'uri'
require 'dragonfly'

begin
  require 'rack/cache'
rescue LoadError => e
  puts "Couldn't find rack-cache - make sure you have it in your Gemfile:"
  puts "  gem 'rack-cache', :require => 'rack/cache'"
  puts " or configure dragonfly manually instead of using 'dragonfly/rails/images'"
  raise e
end

app = Dragonfly[:attachment_uploads]
app.configure_with(:rails)

app.configure do |c|
  c.datastore.configure do |dc|
    dc.root_path = Rails.application.config.dragonfly_root_path

    if Rails.application.config.action_controller.relative_url_root.present?
      rel = Rails.application.config.action_controller.relative_url_root

      # c.server.url_format = "#{rel}/media/:job/:basename.:format"

      c.define_url do |app, job, opts|
        "#{rel}#{app.server.url_for(job, opts)}"
      end
    end
  end
end

if defined?(ActiveRecord::Base)
	app.define_macro(ActiveRecord::Base, :file_accessor)
end

if defined?(Import)
  app.define_macro(Importy, :file_accessor)
end

Rails.application.middleware.insert 0, Dragonfly::Middleware, :attachment_uploads