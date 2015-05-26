module ApplicationHelper
  def show_fields(object, *fields)
    output = ''
    fields.each do |field|
      field_name = object.class.human_attribute_name(field)
      output << classy_field(field_name, object.send(field).to_s)
    end

    output.html_safe
  end


  def classy_field(label, content = "", &block)
    label_div = content_tag :div, label, :class => "live-event-details-label"
    if block_given?
      content = capture(&block)
    end
    value_div = content_tag :div, content, :class => "live-event-details-text"
    clear_div = content_tag :div, "", :class => "clear"

    content_tag(:div, (label_div << value_div << clear_div), {:class => "live-event-details"}, false).html_safe
  end

  def autocomplete_field(name, autocomplete_path)
    f = text_field_tag(name, "", :"data-autocomplete" => autocomplete_path).html_safe
    h = hidden_field_tag("_autocomplete_#{name}").html_safe

    (f << h)
  end

  def search_autocomplete(name, autocomplete_path)
    search_field_tag(name, "", :"data-search-autocomplete" => autocomplete_path).html_safe
  end

  def classy_button_to(name, options = {}, html_options = {})
    button_to_with_extra_class name, "classy", options, html_options
  end

  def in_form_button_to(name, options = {}, html_options = {})
    button_to_with_extra_class name, "in-form", options, html_options
  end

  def button_to_with_extra_class(name, extra_class, options = {}, html_options = {})
    button = button_to(name, options, html_options).html_safe
    content_tag :div, button, :class => "button-wrapper " + extra_class
  end

  def toggle_button(name, path, state, options = {})
    options.assert_valid_keys(:on, :off)

     cb = check_box_tag name, name, state,
        :"data-toggle-action" => path,
        :"data-on-state" => options[:on],
        :"data-off-state" => options[:off]
    label = label_tag name, state ? options[:on] : options[:off]

    (cb << label)
  end

  def phone_numbers_form(parent_form, attribute_name, kinds = PhoneNumber::KINDS)
    render :partial => "phone_numbers/phone_numbers_form",
           :locals => {:parent_form => parent_form, :attribute_name => attribute_name, :kinds => kinds}
  end

  def show_phone_numbers(collection)
    render :partial => "phone_numbers/phone_numbers",
           :object => collection
  end

  def addresses_form(parent_form, attribute_name, kinds = Address::KINDS, allow_destroy = false)
    render :partial => "addresses/addresses_form",
           :locals => {:parent_form => parent_form, :attribute_name => attribute_name, :kinds => kinds, :allow_destroy => allow_destroy}
  end

  def show_addresses(collection)
    render :partial => "addresses/addresses",
           :object  => collection
  end

  def button_row(&block)
    content = if block_given?
      capture(&block)
    else
      ""
    end

    content_tag :div, content, :class => "button-row" unless content.blank?
  end

  def link_to_if_permitted(action, object, title, *args)
    internal_link_to_if_permitted :link_to, action, object, title, *args
  end

  def button_to_if_permitted(action, object, title, *args)
    internal_link_to_if_permitted :button_to, action, object, title, *args
  end

  def hide_navigation
    @hide_navigation = true
  end

  def hide_english_locale
    @hide_english_locale = true
  end

  def full_screen
    @full_screen = true
  end

  def submit_row(form_builder)
    back = if @destination
             link_to t(:back), @destination
           elsif content_for?(:back)
             content_for(:back)
           else
             nil
           end
    form_builder.classy_submit nil, back
  end
  
  def link_to_locale(locale, options = {})
    current_locale = I18n.locale.to_sym
    current_class = options[:class]
    
    current_class = ((current_class || "") + " toggled").chomp if locale == current_locale
    options.merge!(:class => current_class) if current_class
    
    link_to t("nav.#{locale}"), url_for(:locale => locale), options
  end

  def html_text(key)
    content_tag(:div, t(key), :class => "text")
  end
  private

  def internal_link_to_if_permitted(link, action, object, title, *args)
    if permitted_to? action, object
      path = case object
      when Symbol
        if object == :index
          self.send(:"#{object}_path")
        else
          self.send(:"new_#{object.to_s.singularize.underscore}_path")
        end
      else
        if [:destroy, :show].include?(action)
          self.send(:"#{object.class.to_s.underscore}_path", object)
        else
          self.send(:"#{action}_#{object.class.to_s.underscore}_path", object)
        end
      end

      if action == :destroy
        opts = args.extract_options! || {}
        opts[:method] = :delete

        args = args + [opts]
      end
      send link, title, path, *args
    end
  end

  def options_for_gender
    Candidate::GENDERS.map { |s| [t(s, :scope => :sex), s] }
  end
  
  def show_last_modified(object)
    render "shared/last_modified", :object => object
  end

  def salutation(person)
    sex = (person.respond_to?(:sex) ? person.sex.upcase : 'N') || 'N'
    name = person.respond_to?(:last_name) ? person.last_name : person.to_s
    title = person.respond_to?(:title) ? normalized_title(person.title) : nil

    scopes = [:salutation, title].reject(&:nil?)

    I18n.t sex, :scope => scopes
  end


  def normalized_title(title)
    case title
    when /prof\..*dr\./i
      :prof
    when /(dr|pract)\..**med\./i
      :dr
    else
      nil
    end
  end

  def exam_candidate_status(exam_candidate)
    if exam_candidate.status == :sgdv_approval_pending
      "Exam Comission Approaval Pending"
    else
      exam_candidate.status.to_s.humanize
    end
  end
end