require 'set'

class MemberCandidate < Candidate
  ACCEPTANCE_STATUSES = [:applied, :no_membership, :exam_candidate, :am, :em, :km, :om, :pm]

  has_one :phone_number, :as => :phone_owner, :autosave => true, :dependent => :destroy
  accepts_nested_attributes_for :phone_number, :allow_destroy => true
  validates_associated :phone_number

  has_many :places_of_work, :class_name => "PlaceOfWork",
           :foreign_key => "candidate_id", :order => "date_to DESC"
  accepts_nested_attributes_for :places_of_work,
                                :allow_destroy => true, :reject_if => :blank_internship?
  validates_associated :places_of_work

  validates :university, :disertation, :date_of_dermatology_diploma, :first_recommender,
            :second_recommender, :language,
            :presence => true

  validates :date_of_dermatology_diploma, :date => true

  validate :email_must_be_unique_system_wide

  default_scope order(:first_name, :last_name)

  scope :with_term, lambda { |term|
    relation = scoped

    term.split(/\s+/).reduce(relation) do |relation, word|
      word = "%#{word}%"
      relation.where(:first_name.matches % word | :last_name.matches % word)
    end
  }

  scope :with_status, lambda { |status|
    if :all == status.to_sym
      scoped
    else
      where(:acceptance_status => status)
    end
  }

  search_methods :with_term, :with_status

  def year_of_dermatology_diploma
    date_of_dermatology_diploma.year
  end

  def to_member
    transfer_attributes = [:first_name, :last_name, :language,
                           :title, :date_of_birth].to_set

    member_attrs = Hash[attributes.select { |k, v| transfer_attributes.include?(k.to_sym) }]
    member_attrs.merge!(:sex                 => gender,
                        :email               => email_address,
                        :email_confirmation  => email_address,
                        :username            => email_address,
                        :password            => email_address)

    member = Member.new(member_attrs)

    member.memberships.build(
      :nomination          => nomination_for_acceptance_status,
      :from_date           => Date.today,
      :membership_category => MembershipCategory.find_by_name_and_kind("A", "SGDV"))

    member.phone_numbers.build(phone_number.attributes.except(:phone_number_id,
                                                              :phone_nuber_type))
    member.addresses.build(address.attributes.except(:address_owner_id,
                                                     :address_owner_type))


    member.add_default_groups

    member
  end

  def nomination_for_acceptance_status
    case acceptance_status.to_sym
    when :am
      "Ausserordentliches Mitglied (AM)"
    when :em
      "Ehrenmitglied (EM)"
    when :km
      "Korrespondierendes Mitglied (KM)"
    when :om
      "Ordentliches Mitglied (OM)"
    when :pm
      "Passivmitglied (PM)"
    else
      raise "Acceptance status not in list of acceptable statuses"
    end
  end

  def email_must_be_unique_system_wide
    errors.add(:email_address, "has already been taken") if Member.find_by_email(email_address).present?
  end
end
