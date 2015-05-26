require 'action_view/helpers'

class SimpleFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper

  def label(method, *args)
    if required?(method)
      output = super
    
      output.gsub!(/<\/label/, "*</label")
    
      output.html_safe
    else
      super
    end
  end

  def required?(method)
    return false unless object.class.respond_to?(:validators_on)

    object.class.validators_on(method).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }  
  end

  def classy_text_field(label_or_field, field = nil)
    classy_form_field(:text_field, label_or_field, field)
  end

  def hinted_text_field(label_or_field, field, hint = nil)
    label_or_field, field, hint = label_or_field, nil, field unless hint
    
    classy_form_field(:text_field, label_or_field, field, nil, :hint => hint)
  end

  def classy_date_select(label_or_field, field = nil)
    classy_form_field(:date_select, label_or_field, field, "intristic", 
                      :use_month_numbers => true,
                      :start_year => Time.now.year - 20)
  end

  def classy_date_field(label_or_field, field = nil)
    classy_form_field(:text_field, label_or_field, field, nil, {:"data-date" => true})
  end

  def classy_birth_select(label_or_field, field = nil)
    classy_form_field(:date_select,
                      label_or_field,
                      field,
                      "intristic",
                      :use_month_numbers => true, 
                      :start_year => 1900, 
                      :end_year => Time.now.year)
  end

  def classy_month_select(label_or_field, field = nil)
    classy_form_field(:date_select, label_or_field, field, "intristic", 
                      :use_month_numbers => true, 
                      :discard_day => true,
                      :start_year => Time.now.year - 20)
  end

  def classy_year_select(label_or_field, field = nil)
    classy_form_field(:date_select, label_or_field, field, "intristic", 
                      :use_month_numbers => true, 
                      :discard_day => true,
                      :discard_month => true,
                      :start_year => Time.now.year - 20)
  end

  def classy_time_select(label_or_field, field = nil)
    classy_form_field(:time_select, label_or_field, field, "intristic")
  end

  def classy_text_area(label_or_field, field = nil)
    classy_form_field(:text_area, label_or_field, field)
  end

  def hinted_text_area(label_or_field, field, hint = nil)
    label_or_field, field, hint = label_or_field, nil, field unless hint
    
    classy_form_field(:text_area, label_or_field, field, nil, :hint => hint)
  end

  def classy_email_field(label_or_field, field = nil)
    classy_form_field(:email_field, label_or_field, field)
  end
  def classy_file_field(label_or_field, field = nil)
    field = classy_form_field(:file_field, label_or_field, field).html_safe

  end

  def classy_attachment_upload(label)
    upload_field = case 
                   when object.uploaded_file && object.uploaded_file.retained?
                    classy_form_field(:file_field, label, :uploaded_file, nil, 
                      :hint => "Already uploaded: #{object.uploaded_file.retained_attrs[:name]}")
                    when object.new_record?
                      classy_form_field(:file_field, label, :uploaded_file)
                    else
                      classy_form_field(:file_field, label, :uploaded_file, nil, :hint => "Current: #{object.uploaded_file.name}")
                    end.html_safe
      retain_field = hidden_field(:retained_uploaded_file).html_safe

      (upload_field << retain_field)
    end

  def classy_password_field(label_or_field, field = nil)
    classy_form_field(:password_field, label_or_field, field)
  end

  def classy_check_box(label_or_field, field = nil)
    if field == nil
      field = label_or_field
      label_tag = label(field).html_safe
    else
      label_tag = content_tag(:label, label_or_field).html_safe
    end

    field_tag = check_box(field).html_safe

    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (field_tag << label_tag << clear_tag), :class => "intristic check-box"
  end

  def hinted_check_box(label_or_field, field, hint = nil)
    label_or_field, field, hint = label_or_field, nil, field unless hint
    if field == nil
      field = label_or_field
      label_tag = label(field).html_safe
    else
      label_tag = content_tag(:label, label_or_field).html_safe
    end
    
    hint_tag = content_tag(:span, hint, :class => "hint").html_safe

    field_tag = check_box(field).html_safe 

    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (field_tag << label_tag << hint_tag << clear_tag), :class => "intristic check-box"
  end
  def classy_submit(button_label = nil, back = nil)
    button_label = button_label || I18n.translate("submit")
    content_tag :div, (content_tag(:button, button_label, :type => "submit").html_safe << back), :class => "button-row"
  end

  def classy_collection_select(field, collection, value_id, description_id)
    label_tag = label(field).html_safe
    field_tag = collection_select(field, collection, value_id, description_id).html_safe
    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (label_tag << field_tag << clear_tag)
  end

  def classy_select(field, collection)
    label_tag = label(field).html_safe
    field_tag = select(field, collection).html_safe
    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (label_tag << field_tag << clear_tag)
  end

  def classy_small_select(field, collection)
    label_tag = label(field).html_safe
    field_tag = select(field, collection).html_safe
    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (label_tag << field_tag << clear_tag), :class => "small"
  end

  def classy_labeled_select(label, field, collection)
    label_tag = label_tag(label)
    field_tag = select(field, collection).html_safe
    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (label_tag << field_tag << clear_tag)
  end

  def classy_autocomplete(label_or_field, field, autocomplete_path=nil)
    if autocomplete_path == nil
      autocomplete_path = field
      field = label_or_field
      label_tag = label(field).html_safe
    else
      label_tag = content_tag(:label, label_or_field).html_safe
    end

    field_tag = hidden_field(field).html_safe

    if field_tag =~ /id="(.+?)"/
      id = $1
    else
      id = ""
    end
    autocomplete_tag = text_field_tag("_autocomplete_#{@object_name}_#{field}", @object.send(field),
                                    {:"data-autocomplete" => autocomplete_path.html_safe,
                                     :"data-id-element" => id}).html_safe



    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (label_tag << autocomplete_tag << field_tag << clear_tag)
  end
  
  def hinted_autocomplete(field, autocomplete_path, hint)
    
    label_tag = label(field).html_safe
    field_tag = hidden_field(field).html_safe
    hint_tag = content_tag(:span, hint, :class => "hint").html_safe

    if field_tag =~ /id="(.+?)"/
      id = $1
    else
      id = ""
    end
    autocomplete_tag = text_field_tag("_autocomplete_#{@object_name}_#{field}", @object.send(field),
                                    {:"data-autocomplete" => autocomplete_path.html_safe,
                                     :"data-id-element" => id}).html_safe



    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (label_tag << autocomplete_tag << field_tag << hint_tag << clear_tag)
  end

  def search_autocomplete(field, autocomplete_path)
    search_field(field, :"data-search-autocomplete" => autocomplete_path.html_safe)
  end

  def classy_radio_selection(label, field, *values)
    label_tag = label(field).html_safe
    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    field_tags = values.each_slice(2).map do |label, value|
      radio = radio_button(field, value).html_safe
      text = content_tag(:span, label).html_safe

      content_tag(:p, (radio << text)).html_safe
    end

    content_tag :div, (label_tag << field_tags.join("\n").html_safe), :class => "rgroup intristic"
  end

  def classy_login_field(field)
    label_tag = label(field).html_safe
    field_tag = self.text_field(field, :autocomplete => "off").html_safe

    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    content_tag :div, (label_tag << field_tag << clear_tag)
  end

  private

  def classy_form_field(kind, label_or_field, field = nil, extra_class = nil, *args)
    options = args.dup.extract_options!

    if field == nil
      field = label_or_field
      label_tag = label(field).html_safe
    else
      label_tag = content_tag(:label, label_or_field).html_safe
    end

    field_tag = self.send(kind, field, *args).html_safe

    clear_tag = content_tag(:div, "", :class => "clear").html_safe

    hint_tag = if options[:hint] then content_tag(:span, options[:hint], :class => "hint").html_safe else "" end

    if extra_class
      content_tag :div, (label_tag << field_tag << hint_tag << clear_tag), :class => extra_class
    else
      content_tag :div, (label_tag << field_tag << hint_tag << clear_tag)
    end
  end


end
