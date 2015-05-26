class Import
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :resolved_members
  alias :resolved_members? :resolved_members

  attr_accessor :actions
  attr_reader :data_file
  attr_reader :results

  validates :data_file, :presence => true

  class Action < Struct.new(:action, :attributes)
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    ATTRIBUTES = [
      :sex,
      :title,
      :memberships_attributes,
      :first_name,
      :middle_name,
      :last_name,
      :posts_attributes,
      :addresses_attributes,
      :homepage,
      :email,
      :phone_numbers_attributes,
      :date_of_birth,
      :language
    ]

    ACTIONS = [:unknown, :insert, :update, :ignore, :invalid]

    # attr_accesible :action 
    validates :action, :presence => true, :inclusion => {:in => ACTIONS}

    def initialize(attributes = {})
      super *attributes.values_at(:action, :attributes)

      attributes.reject {|k| [:action, :attributes].include? k }.each do |name, value|
        send("#{name}=", value)
      end
    end

    def to_s
      attributes.values_at(:title, :first_name, :middle_name, :last_name)
                .reject(&:nil?)
                .join(" ") || ""
    end

    def persisted?
      false
    end

    def associated_member
      @associated_member ||= (Member.find(@associated_member_id) if @associated_member_id)
    end

    def associated_member=(member)
      @associated_member_id = member ? member.id : nil
      @associated_member = member

      if self.associated_member
        self.action = :update
        resolve_associated_object_ids!
      else
        self.action = :insert
        resolve_posts_to_clinics!
        resolve_associated_membership!
        attributes[:username] = attributes[:password] = attributes[:email]
      end
    end

    def changed?
      associated_member.changed?
    end

    def attribute_at(path)
      path = [path] unless path.is_a?(Enumerable)

      obj = attributes
      path.reduce(obj) do |obj, key|
        if obj
          key = key.to_sym if key.is_a?(String)
          obj[key]
        else
          nil
        end
      end
    end

    def descend_enum(obj, path)
      path = [path] unless path.is_a?(Enumerable)
      current = obj

      Enumerator.new do |y|
        y.yield [current, nil, nil]

        path.each do |key|
          key = key.to_sym if key.is_a?(String)
          association = association_for key
          accessor = association || key

          current = case
                    when accessor.is_a?(Symbol) && current.respond_to?(accessor)
                      current.send accessor
                    when current.respond_to?(:"[]")
                      current[accessor]
                    else
                      nil
                    end

          y.yield [current, accessor, !!association]
        end
      end
    end

    def find_object_and_accessor(obj, path)
      descendants = descend_enum obj, path
      last = descendants.each_cons(2).to_a.last
      (parent, *), (val, accessor, association) = last

      if parent and accessor
        yield parent, accessor, val, association
      else
        nil
      end
    end

    
    def attribute_changed?(attribute) 
      find_object_and_accessor associated_member, attribute do |obj, accessor, val, association|
        if association
          associated_obj = obj.send(accessor)
          if associated_obj.is_a?(Enumerable)
            associated_obj.map(&:changed?).reduce{|a, b| a || b}
          else
            associated_obj.changed?
          end
        else
          obj.send :"#{accessor}_changed?"
        end
      end
    end

    def original_for(attribute)
      find_object_and_accessor associated_member, attribute do |obj, accessor, val, association|
        if association
          nil
        else
          obj.send :"#{accessor}_was"
        end
      end
    end

    def actions_attributes=(attributes)
      require 'pp'
      pp attributes
    end

    # marshalling

    def marshal_dump
      @associated_member = nil # some crazy bug makes ruby serialize this as well
      [action, attributes, @associated_member_id]
    end

    def marshal_load(array)
      self.action, self.attributes, @associated_member_id = array
    end

    private

    def association_for(attribute)
      case attribute

      when Numeric
        nil

      when /^(.+)_attributes$/
        $1.to_sym

      else
        nil
      end
    end

    def resolve_associated_object_ids!
      if @associated_member
        resolve_associated_post!
        resolve_associated_phone_number!
        resolve_associated_address!
        resolve_associated_membership!
      end
    end

    def resolve_posts_to_clinics!
      posts_attributes = attributes[:posts_attributes]
      post_facility_attributes = posts_attributes.first if posts_attributes
      facility_attributes = post_facility_attributes[:facility_attributes] if post_facility_attributes

      if facility_attributes
        address_attributes = facility_attributes[:addresses_attributes].find{|a| a[:kind] == "business"} || {}

        query = {:addresses => {
                   :kind => "business",
                   :street1 => address_attributes[:street1],
                   :street2 =>  address_attributes[:street2],
                   :postal_code => address_attributes[:postal_code]}.reject { |k, v| v.blank? },
                }
        facility = Facility.joins(:addresses).where(query).first
      end

      if facility and facility_attributes
        post_facility_attributes[:facility_id] = facility.id
        post_facility_attributes[:function] = "Unknown"
        post_facility_attributes.delete :facility_attributes
      end
    end

    def resolve_associated_post!
      posts_attributes = attributes[:posts_attributes]
      post_praxis_attributes = posts_attributes.first if posts_attributes
      praxis_attributes = post_praxis_attributes[:facility_attributes] if post_praxis_attributes

      if praxis_attributes
        address_attributes = praxis_attributes[:addresses_attributes].find{|a| a[:kind] == "business"} || {}

        query = {:addresses => {
                   :kind => "business",
                   :street1 => address_attributes[:street1],
                   :street2 =>  address_attributes[:street2],
                   :postal_code => address_attributes[:postal_code]}.reject { |k, v| v.blank? },
                 :kind => "praxis" # allow updates only of praxis records, not unverisities
                }
        facility = @associated_member.facilities.joins(:addresses).where(query).first
      end

      if facility and praxis_attributes
        posts = facility.posts

        praxis_attributes[:id] = facility.id
        posts_attributes.first[:id] = posts.where(:member_id => @associated_member.id).first.id

        # business address 
        addresses_attributes = praxis_attributes[:addresses_attributes]
        resolve_address! addresses_attributes, facility.addresses, "business" if addresses_attributes

        # phone numbers
        phone_numbers_attributes  = praxis_attributes[:phone_numbers_attributes]
        if phone_numbers_attributes
          resolve_phone_number! phone_numbers_attributes, facility.phone_numbers, "business"
          resolve_phone_number! phone_numbers_attributes, facility.phone_numbers, "fax"
        end
      else
        # no praxis found, discard import data
        attributes.delete(:posts_attributes)
      end
    end

    def resolve_associated_address!
      addresses_attributes = attributes[:addresses_attributes]
      resolve_address! addresses_attributes, @associated_member.addresses, "private" if addresses_attributes
    end

    def resolve_associated_phone_number!
      phone_numbers_attributes = attributes[:phone_numbers_attributes]
      resolve_phone_number! phone_numbers_attributes, @associated_member.phone_numbers, "private" if phone_numbers_attributes
    end

    def resolve_address!(addresses_attributes, relation, kind)
      specific_address_attributes = addresses_attributes.find { |a| a[:kind] == kind }
      specific_address = relation.where(:kind => kind).first

      if specific_address_attributes and specific_address
        specific_address_attributes[:id] = specific_address.id
      else
        # no address found, discard data
        addresses_attributes.delete_if { |a| a[:kind] == kind }
      end
    end

    def resolve_phone_number!(phone_numbers_attributes, relation, kind)
      specific_phone_number_attributes = phone_numbers_attributes.find { |p| p[:kind] == kind }
      specific_phone_number = relation.where(:kind => kind).first

      if specific_phone_number_attributes and specific_phone_number
        specific_phone_number_attributes[:id] = specific_phone_number.id
      else
        phone_numbers_attributes.delete_if { |p| p[:kind] == kind }
      end
    end

    def resolve_associated_membership!
      membership_attributes = attributes[:memberships_attributes].first

      categories = membership_category_mapping

      category = membership_attributes.delete(:membership_category)
      category_id = categories[category]

      membership = associated_member.memberships.sgdv.first if associated_member

      if category_id
        membership_attributes[:membership_category_id] = Integer(category_id)
        membership_attributes[:from_date] = Date.today if action == :insert
      else
        attributes[:membership_attributes] = []
      end

      if membership
        membership_attributes[:id] = membership.id
      end

    end

    def membership_category_mapping
      Hash[MembershipCategory.where(:kind => "SGDV").map do |c|
        [c.name, c.id]
      end]
    end

  end


  class Result < Struct.new(:outcome, :description, :associated_member, :messages)
    OUTCOMES = [:success, :ignore, :failure]
  end


  def self.load(session)
    session[:member_import]
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end if attributes
  end

  def apply_changes
    actions.select{|a| a.action == :update}.each do |action|
      action.associated_member.attributes = action.attributes
    end
  end

  def update_actions(from_user)
    actions.each.with_index do |action, index|
      new_action_data = from_user[index.to_s]
      new_action = new_action_data[:action] if new_action_data
      action.action = new_action.to_sym if new_action
    end
  end

  def import_in_db!
    @results = actions.map do |action|
      case action.action

      when :insert
        new_member = Member.new(action.attributes)
        new_member.add_default_groups
        new_member.save

        if new_member.errors.any?
          Result.new(:failure, action.to_s, new_member, new_member.errors.full_messages)
        else
          Result.new(:success, action.to_s, new_member, [])
        end

      when :update
        success = action.associated_member.save
        if success
          Result.new(:success, action.to_s, action.associated_member, [])
        else
          Result.new(:failure, action.to_s, action.associated_member, action.associated_member.errors.full_messages)
        end

      when :ignore
        Result.new(:ignore, action.to_s, action.associated_member, [])
      end 
    end
  end

  def actions
    unless resolved_members?
      resolve_members!(@actions)
      self.resolved_members = true
    end

    @actions 
  end

  def unresolved_actions
    @actions
  end

  def data_file=(data_file)
    @data_file = data_file
    Rails.logger.info "Will import actions from #{data_file.path}"
    self.data_file_path = data_file.path
  end

  def data_file_path=(data_file_path)
    self.actions = Import.import_actions_from(data_file_path.to_s)
  end


  def save(session)
    if valid? 
      session[:member_import] = self
      true
    else
      false
    end
  end


  def persisted?
    false
  end

  def marshal_dump
    [actions, resolved_members?]
  end

  def marshal_load(data)
    self.actions, self.resolved_members = data
  end

  private

  def resolve_members!(actions)
    actions.each do |action|
      action.associated_member = member_for_action(action)
    end   
  end

  def member_for_action(action)
    member_by_name(action) or
    member_by_email(action)
  end

  def member_by_name(action)
    potential = Member.with_name action.attributes[:first_name],
                                 action.attributes[:last_name],
                                 action.attributes[:middle_name]

    if potential.count == 1
      potential.first
    else
      nil
    end
  end
  
  def member_by_email(action)
    Member.find_by_email(action.attributes[:email])
  end


  class << self


    # produces an array of Import actions to be performed based
    # on th eprovided excel file
    def import_actions_from(excel_file)
      worksheet = worksheet_from(excel_file)
      actions_from_worksheet(each_row(worksheet))
    end
 
    private
 
    def worksheet_from(excel_file)
      RubyXL::Parser.parse(excel_file).worksheets[0]
    end
 
    def actions_from_worksheet(worksheet)
      worksheet.map do |row|
        action_for_row row
      end
    end
 
    def action_for_row(row)
      attributes = strip_nills(parse_attributes(row))
      strip_empty!(attributes, :addresses_attributes, :street1)
      strip_empty!(attributes, :phone_numbers_attributes, :number)

      strip_empty!(attributes[:posts_attributes][0][:facility_attributes], :phone_numbers_attributes, :number)
      strip_empty!(attributes[:posts_attributes][0][:facility_attributes], :addresses_attributes, :street1)
 
      Action.new(:action => :unknown, :attributes => attributes)
    end
 
    def parse_attributes(row)
      {
        :sex => sex_for(textual(row[0])),
        :title => textual(row[1]),
        :memberships_attributes => [ membership_attributes(textual(row[2])) ],
        :first_name => textual(row[3]),
        :middle_name => textual(row[4]),
        :last_name => textual(row[5]),
        :posts_attributes => [
          {
            :function => "Praxis",
            :facility_attributes => {
              :kind => "praxis",
              :name => textual(row[6]),
              :department => textual(row[7]),
              :phone_numbers_attributes => [
                {
                  :kind => "business",
                  :number => textual(row[18])
                },
                {
                  :kind => "fax",
                  :number => textual(row[19])
                }                
              ],
              :addresses_attributes => [
                { 
                  :kind => "business",
                  :street1 => textual(row[8]),
                  :street2 => textual(row[9]),
                  :postal_code => textual(row[10]),
                  :city => textual(row[11]),
                  :canton => textual(row[12]),
                  :country => textual(row[13])
                }                
              ] 
            }
          }
        ],
        :addresses_attributes => [
          {
            :kind => "private",
            :street1 => textual(row[20]),
            :postal_code => textual(row[21]),
            :city => textual(row[22]),
            :canton => textual(row[23]),
            :country => "CH"
          }
        ],
        :homepage => textual(row[14]),
        :email => textual(row[16]),
        :phone_numbers_attributes => [
          {
            :kind => "private",
            :number => textual(row[24])
          }
        ],
        :date_of_birth => date_like(row[25]),
        :language => language_for(row[1])
      }
    end
 
    def each_row(worksheet)
      Enumerator.new do |yielder|
        (1...worksheet.sheet_data.size).each do |i|
          yielder.yield worksheet.sheet_data[i] if worksheet.sheet_data[i].present?
        end
      end
    end
 
    def strip_nills(member)
      Hash[member.flat_map do |k, v|
        case 
        when v.blank?
          []

        when v.is_a?(Array)
          [[k, v.map { |r| strip_nills(r) }]]

        when v.is_a?(Hash)
          [[k, strip_nills(v)]]

        else 
          [[k, v]]
        end
      end]
    end
 
    def strip_empty!(member, field, test_field)
      member[field].delete_if { |a| a[test_field].blank? }
    end
 
 
    def sex_for(text)
      case text
      when /frau/i, /madame/i then "F"
      when /herr/i, /monsieur/i then "M"
      else "M"
      end
    end

    def language_for(text)
      return "de" if text.blank? || text.value.blank?

      case text.value
      when /le +docteur/i, /le +professeur/ then "fr"
      when /dr\. *med\./i then "de"
      else "de"
      end
    end
 
    def membership_attributes(text)
      category, nomination = case text
                             when /^([ABCDEFG]):\s*(.*)\s*$/i
                               ["#{$1.upcase}", $2]
                             else
                               ["A", "Ausserordentliches Mitglied / Membres extraordinaire"]
                             end
                             
      { :membership_category => category,
        :nomination => nomination }
    end
 
    def textual(text)
      if text.blank?
        nil
      else 
        text.value.to_s.strip
      end
    end
 
    def date_like(text)
      case
      when text.blank? || text.value.blank?
        nil
      when text.is_date?
        text.value
      else
        Date.parse(text.value) rescue Date.strptime(text.value, "%m/%d/%y") rescue nil
      end
    end
  end

end