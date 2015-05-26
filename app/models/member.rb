class Member < ActiveRecord::Base
  
  LANGUAGES = [:de, :fr]
  SEXES     = [:M, :F]
  
  DEFAULT_GROUPS = %w{sgdv-member SGDV_DISCUSSION_denyAccess SGDV_EXAM_denyAccess 
                      SGDV-Klinikdirektoren_denyAccess 
                      SGDV-ausschuss-denyAccess}.map(&:to_sym)

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :middle_name, :title, :username,
                  :email, :password, :password_confirmation, :remember_me,
                  :language, :date_of_birth, :sex, :homepage,
                  :phone_numbers_attributes, :addresses_attributes,
                  :hide_in_addressbook, :posts_attributes, :memberships_attributes

  validates :first_name, :last_name, :presence => true
  validates :username, :email, :uniqueness => true

  has_and_belongs_to_many :groups

  has_many :posts, :autosave  => true, :dependent => :destroy
  has_many :facilities, :through => :posts, :include => :posts

  accepts_nested_attributes_for :posts, :allow_destroy => false

  has_many :phone_numbers, :as => :phone_owner, :autosave => true, :dependent => :destroy
  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true, :reject_if => :blank_phone_number?
  validates_associated :phone_numbers

  has_many :addresses, :as => :address_owner, :autosave => true , :dependent => :destroy
  accepts_nested_attributes_for :addresses,:allow_destroy => true, :reject_if => :blank_address?

  has_many :designations, :dependent => :destroy, :autosave => true

  has_many :memberships, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :memberships
  validates_associated :memberships

  scope :addressbook, where(:username.not_eq => "superuser", :hide_in_addressbook => false).
                      order(:last_name, :first_name)

  scope :addressbook_list, addressbook.includes(:phone_numbers, 
    :posts =>{:facility => [:addresses, :phone_numbers]}, :memberships => :membership_category)

  scope :with_term, lambda { |term|
    clauses = []
    words = {}
    constr = term.strip.split(/\s+/).each_with_index do |w, i|
      w_name = :"term#{i}"
      w_value = "%#{w.downcase}%"

      words[w_name] = w_value

      clauses << <<-QUERY
        (lower(first_name) like :#{w_name}
        or lower(last_name) like :#{w_name}
        or lower(middle_name) like :#{w_name}
        or lower(username) like :#{w_name}
        or lower(email) like :#{w_name})
      QUERY
    end

    constraints = [clauses.join(" AND "), words]

    select("DISTINCT members.*").where(*constraints).order(:first_name, :last_name)
  }

  scope :with_personal_info_term, lambda { |term|
    relation = addressbook_list.select("distinct members.*")

    term.split(/\s+/).reduce(relation) do |relation, word|
      word = "%#{word}%"
      relation.where(:first_name.matches   % word |
                     :last_name.matches    % word |
                     :middle_name.matches  % word)
    end
  }

  scope :with_business_info_term, lambda { |term|
    relation = addressbook_list.select("distinct members.*").
                                joins(:facilities => [:addresses])

    pattern = "#{term}%".gsub(/\./, '%')
    relation.where(:facilities =>
                   {:name.matches => pattern}                           |
                   {:addresses => 
                     {:street1.matches => pattern}                      |
                     {:street2.matches => pattern}})
  }

  scope :with_canton_postal_term, lambda { |term|
    relation = addressbook_list.select("distinct members.*").
                                joins(:facilities => [:addresses])

    pattern = "#{term}%"
    word = term
    relation.where(:facilities =>
                   {:name.matches => pattern}         |
                   {:addresses => 
                       {:postal_code.eq  => word}     |
                       {:canton.eq       => word}     |
                       {:city.matches    => pattern}})
  }

  scope :with_equipment_term, lambda { |term|
    relation = addressbook_list.select("distinct members.*").
                                includes(:facilities => {:equipment => :equipment_type}).
                                joins(:facilities => {:equipment => :equipment_type})

    term.split(/\s+/).reduce(relation) do |relation, word|
      pattern = "%#{word}%"

      relation.where(:facilities =>
                      {:equipment => {:description.matches => pattern} |
                                     {:equipment_type => {:kind.matches => pattern}}})
    end
  }
  
  scope :with_specialization_term, lambda { |term| 
    relation = addressbook_list.select("distinct members.*").
                                joins(:designations => :organizational_unit)
    
    pattern = "%#{term}%"
    relation.where(:designations => {
                     :organizational_unit => {
                       :name.matches => pattern,
                       :tag => "specialization"}})
  }

  scope :with_membership_category_name,  lambda { |name| 
    select("DISTINCT members.*").
    joins(:memberships => :membership_category).
    where(:memberships => {:membership_category => {:name => name}})
  }
  
  scope :with_kind, lambda { |kind|
    if kind == "all" or kind.blank?
      scoped
    elsif "Hidden" == kind
      where(:hide_in_addressbook => true)
    elsif "Passed Away" == kind
      with_membership_category_name("Verstrorben")
    elsif "Company" == kind
      with_membership_category_name("Firma")
    elsif "Ordinary Members" == kind
      select("DISTINCT members.*").
      joins(:memberships => :membership_category).
      where(:memberships => 
              {:nomination => "Ordentliches Mitglied / Membre ordinaire", 
               :membership_category => {:kind => "SGDV"}})
    else
      select("DISTINCT members.*").
      joins(:memberships => :membership_category).
      where(:memberships =>
              {:membership_category => {:kind => kind}})
    end
  }

  scope :with_name, lambda { |first, last, middle|
    where(:first_name => first, :last_name => last, :middle_name => middle)
  }

  search_methods :with_term, :with_personal_info_term,
                 :with_business_info_term, :with_canton_postal_term, :with_equipment_term,
                 :with_kind, :with_specialization_term, :with_name

  def designations_matching_term(term)
    relation = designations.joins(:organizational_unit)

    term.split(/\s+/).reduce(relation) do |relation, word|
      pattern = "%#{word}%"

      relation.where({:kind.matches => pattern} |
                     {:organizational_unit => {:name.matches => pattern}})
    end
  end

  def name
    name = ""
    name << title << " " if title?
    name << first_name << " "
    name << middle_name << " " if middle_name?
    name << last_name

    name
  end
  
  def email_address_with_name
    "#{name} <#{email}>"
  end
  
  def localized_sex
    I18n.translate(sex, :scope => :sex)
  end

  def sgdv_nomination
    today = Date.today

    membership = memberships.find_all do |m|
      m.membership_category.kind == "SGDV" &&
        m.from_date < today && (m.to_date.blank? || m.to_date >= today)
    end.first

    membership ? membership.nomination : ""
  end

  def member_of?(group_code)
    groups.find_by_code(group_code.to_s)
  end

  def self.find_for_authentication(conditions)
    Member.where({:username => conditions[:email]} | {:email => conditions[:email]}).first
  end

  def new_facility
    @new_facility
  end

  def new_facility=(a_facility)
    @new_facility = Facility.find(a_facility)
    facilities << @new_facility if @new_facility
  end

  def direct_phone
    phone_numbers.find_all { |p| p.kind == "direct" }.first
  end 

  def roles
    groups.map { |group| group.code.to_sym }
  end

  alias_method :role_symbols, :roles

  def make_password_token!
    generate_reset_password_token!
  end

  
  def add_default_groups
    self.groups += Group.where(:code => DEFAULT_GROUPS).all
  end

  private

  def blank_phone_number?(phone_number_attributes)
    phone_number_attributes['number'].blank?
  end

  def blank_address?(address_attributes)
    %w(street1 postal_code city).all? { |attr| address_attributes[attr].blank? }
  end
  
end
