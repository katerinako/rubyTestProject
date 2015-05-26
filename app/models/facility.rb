class Facility < ActiveRecord::Base
  extend DistinctFields

  KINDS           = [:university_hospital, :clinic, :praxis]
  EDUCATION_TYPES = [:"N/A", :A, :B, :C, :D, :E]

  has_many :phone_numbers, :as => :phone_owner, :autosave => true, :dependent => :destroy
  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true, :reject_if => :blank_phone_number?
  validates_associated :phone_numbers

  has_many :addresses, :as => :address_owner, :autosave => true , :dependent => :destroy
  accepts_nested_attributes_for :addresses,:allow_destroy => true, :reject_if => :blank_address?
  validates_associated :addresses

  has_many :equipment, :autosave => true, :dependent => :destroy
  accepts_nested_attributes_for :equipment, :allow_destroy => true, :reject_if => :blank_equipment?
  validates_associated :equipment

  has_many :posts, :dependent => :destroy, :autosave => true
  has_many :members, :through => :posts

  has_many :exam_candidates, :foreign_key => :current_clinic_id, :dependent => :destroy

  validates :kind, :presence => true

  # searching and scopes

  scope :with_term, lambda { |term|
    matcher = "%#{term}%"
    select("DISTINCT facilities.*").
    joins(:addresses).
    joins(:posts).
    joins(:members).
      where(
        {:name.matches => matcher} |
        {:addresses => ({:street1.matches => matcher} | {:city.matches => matcher})})
  }

  scope :with_kind, lambda { |term| 
    if term != "ALL"
      where(:kind => term) 
    else
      scoped
    end
  }

  scope :with_type_of_education, lambda { |term|
    if term != "EMPTY" and term != "ALL"
      where(:type_of_education => term)
    else
      scoped
    end
  }

  search_methods :with_term, :with_type_of_education, :with_kind

  def description
    if not name.blank?
      name
    elsif business_address
      "#{business_address.street1}, #{business_address.city}"
    else
      "Untitled Facility"
    end
  end
  
  def localized_kind
    I18n.translate(read_attribute(:kind))
  end

  def official_phone_numbers
    phone_numbers.find_all { |pn| ["business", "fax"].include? pn.kind }.uniq
  end
  
  def fax_numbers
    official_phone_numbers.find_all { |pn| pn.kind == "fax" }.uniq
  end
  
  def business_numbers
    official_phone_numbers.find_all { |pn| pn.kind == "business" }.uniq
  end

  def business_address
    addresses.find_all { |addr| addr.kind == "business" }.first
  end

  def equipment_matching_term(term)

    # relation = equipment.joins(:equipment_type)

    # term.split(/\s+/).reduce(relation) do |relation, word|
    #   pattern = "%#{word}%"

    #   relation.where({:description.matches => pattern} |
    #                  {:equipment_type => {:kind.matches => pattern}})
    # end
    term.downcase.split(/\s+/).reduce([]) do |matching, word|
      matching + equipment.find_all { |eq| eq.equipment_type.kind.downcase.include?(word) || eq.description.downcase.include?(word) }
    end
  end

  def director
    post = posts.directors.first
    post ? post.member : nil
  end

  private

  def blank_phone_number?(phone_number_attributes)
    phone_number_attributes['number'].blank?
  end

  def blank_address?(address_attributes)
    %w(street1 postal_code city).all? { |attr| address_attributes[attr].blank? }
  end

  def blank_equipment?(equipment_attributes)
    equipment_attributes['description'].blank?
  end

end
