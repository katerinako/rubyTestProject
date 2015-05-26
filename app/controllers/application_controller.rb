class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  
  def set_locale
    I18n.locale = params[:locale]
  end
  
  def default_url_options(options = {})
    options.merge(:locale => I18n.locale)
  end
  
  protected

  def self.autocomplete_for(model_name, scope_name, options)
    puts "in autocomplete_for: options = #{options}"
    label = options.delete(:label)
    define_method("autocomplete_#{model_name}_#{scope_name}") do

      term = params[:term]

      if term && !term.empty?
        items = model_class(model_name).send(scope_name, term).map do |item|
          {:id => item.id, :label => item.send(label), :value => item.send(label)}
        end
      else
        items = []
      end

      render :json => items
    end

  end

  def breadcrumb(title, link=nil)
    @breadcrumbs ||= []
    @breadcrumbs << [title, link]
  end


  def self.sets_content_for_back
    before_filter do
      @coming_from  = params[:coming_from]

      instance_var = "@#{controller_name.singularize}"
      the_model = instance_variable_get(instance_var.to_sym)

      unless @coming_from.blank?
        @destination = the_model.send(@coming_from.to_sym) rescue nil
      else
        @destination = the_model
      end
    end
  end

  private

  def model_class(model_name)
    model_name.to_s.camelize.constantize
  end
end
