if defined?(JRUBY_VERSION)
  Pathname.class_eval do
    def to_str
      to_s
    end
  end
end

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SgdvBackend::Application.initialize!
