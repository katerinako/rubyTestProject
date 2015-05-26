module ImportsHelper
  def show_attribute(action, attribute)
    method = show_method attribute
    attribute_value = action.attribute_at attribute

    if attribute_value
      changed, original = if action.action == :update
                            [action.attribute_changed?(attribute), 
                             action.original_for(attribute)]
                          else
                            [false, nil]
                          end

      if respond_to? method
        send method, action, attribute_value, :changed => changed, 
                                              :original => original, 
                                              :path => attribute
      else
        show_generic_attribute action, attribute_value, :changed => changed, 
                                                        :original => original,
                                                        :path => attribute
      end
    else
      ""
    end
  end


  def show_generic_attribute(action, attribute_value, opts = {})
    opts.reverse_merge! :changed => false, :original => ""

    content_tag :span, attribute_value, :class => changed_class(opts[:changed]),
                                        :title => "Original: #{(opts[:original] || '')}"
  end


  def show_memberships_attributes(action, attribute, opts = {})    
    opts.reverse_merge! :changed => false, :original => ""
    path = opts[:path]

    show_attribute(action, [path] + [0, :membership_category_id]).html_safe +
      ": " +
      show_attribute(action, [path] + [0, :nomination]).html_safe

  end

  def show_posts_attributes(action, posts, opts = {})
    opts.reverse_merge! :changed => false, :original => "", :action => action

    render :partial => "post", :collection => posts, :locals => opts
  end

  def show_posts_attributes_facility_attributes(action, facility, opts = {})
    opts.reverse_merge! :changed => false, :original => "", :action => action

    render :partial => "facility", :object => facility, :locals => opts
  end

  def show_posts_attributes_facility_attributes_addresses_attributes(action, addresses_attributes, opts = {})
    opts.reverse_merge! :changed => false, :original => false, :action => action

    render :partial => "addresses", :collection => addresses_attributes, :locals => opts
  end

  def show_posts_attributes_facility_attributes_phone_numbers_attributes(action, phone_numbers_attributes, opts = {})
    opts.reverse_merge! :changed => false, :original => false, :action => action

    render :partial => "phone_number", :collection => phone_numbers_attributes, :locals => opts
  end

  def show_addresses_attributes(action, addresses, opts = {})
    opts.reverse_merge! :changed => false, :original => [], :action => action
    opts[:path] = [opts[:path]]

    render :partial => "addresses", :collection => addresses, :locals => opts
  end

  def show_phone_numbers_attributes(action, phone_numbers, opts = {})
    opts.reverse_merge! :changed => false, :original => [], :action => action
    opts[:path] = [opts[:path]]

    render :partial => "phone_number", :collection => phone_numbers, :locals => opts
  end

  def errors_for_associated_member(import_action)
    errors_for_member(import_action.associated_member)
  end

  def errors_for_member(member)
    member.errors.full_messages.join("\n") if member
  end
  
  def valid_actions_for(import_action)
    actions = Import::Action::ACTIONS - [:invalid, :unknown]

    unless import_action.associated_member
      actions -= [:update]
    end

    actions
  end

  def class_for_action(import_action)
    classes = ["import-action", 
               case import_action.action
                 when :insert then "insert"
                 when :update then "update"
                 else nil
               end,
               if import_action.action == :update and import_action.changed?
                 "changed"
               else
                  nil
               end]

    classes.reject(&:nil?).join(" ")
  end

  def changed_class(changed)
    if changed 
      "changed-attribute"
    else
      "unchanged-attribute"
    end
  end


  def show_method(attribute) 
    attribute = [attribute] unless attribute.is_a?(Enumerable)
    attribute = attribute.reject{|k| k.is_a? Numeric}

    :"show_#{attribute.join('_')}"
  end
end
