require 'simple_form_builder'

ActionView::Base.default_form_builder = SimpleFormBuilder

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  case html_tag
  when /<label/
    html_tag
  when /^<(input|select|textarea)/
    tag = $1
    with_error = "<#{tag} data-error='data-error'".html_safe + 
                 html_tag[(tag.length + 1)..-1].html_safe
    with_error
  else
    "<div class=\"field_with_errors\">#{html_tag}</div>".html_safe 
  end
end
