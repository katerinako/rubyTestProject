class Candidate < ActiveRecord::Base
  GENDERS = [:M, :F]
  LANGUAGES = [:de, :fr]

  validates :first_name, :last_name, :gender,
            :date_of_medical_exam,
            :presence => true

  validates :email_address, :presence => true, :confirmation => { :on => :create },
            :email => true


  has_many :attachments, :as => :doc
  accepts_nested_attributes_for :attachments, :allow_destroy => true, :reject_if => :all_blank

  has_one :address, :as => :address_owner, :autosave => true , :dependent => :destroy
  accepts_nested_attributes_for :address, :allow_destroy => true
  validates_associated :address

  has_one :cv, :as => :doc, :class_name => "Attachment",
          :conditions => {:kind => :cv},
          :autosave => true, :dependent => :destroy

  has_one :photo, :as => :doc, :class_name => "Attachment",
          :conditions => {:kind => :photo},
          :autosave => true, :dependent => :destroy

  has_many :recommendation_letters, :as => :doc, :class_name => "Attachment",
           :conditions => {:kind => :recommendation_letter},
           :autosave => true, :dependent => :destroy

  has_many :certifications, :as => :doc, :class_name => "Attachment",
           :conditions => {:kind => :certification},
           :autosave => true, :dependent => :destroy

  accepts_nested_attributes_for :cv, :photo, :recommendation_letters, :certifications,
                                :allow_destroy => true,
                                :reject_if => :all_blank

  validates_associated :cv, :photo, :recommendation_letters, :certifications

  has_many :internships, :order => "date_to DESC"
  accepts_nested_attributes_for :internships, :allow_destroy => true, :reject_if => :blank_internship?
  validates_associated :internships


  def name
    name = "#{first_name} #{last_name}"
    name = "#{title} #{name}" if title?

    name
  end

  def sex
    gender
  end

  def localized_sex
    I18n.translate(sex, :scope => :sex)
  end
  alias :localized_gender :localized_sex

  def email_address_with_name
    "#{name} <#{email_address}>"
  end

  def year_of_medical_exam
    date_of_medical_exam.year
  end

  def documents
    attachments.select {|att| att.kind != 'cv'}

  end

  def documents=(docs)
    return unless docs

    cv_backup = cv
    self.attachments = docs.map {|d| Attachment.new(d)}
    self.attachments << cv_backup if cv_backup
  end


  def total_expirience
    internships.map { |i| i.months  }.sum
  end

  def blank_internship?(attributes)
    attributes['clinic'].blank?
  end

end
