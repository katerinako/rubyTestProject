class Post < ActiveRecord::Base
  belongs_to :member

  belongs_to :facility, :autosave => true
  accepts_nested_attributes_for :facility
  validates_associated :facility
  
  validates :function, :presence => true

  # validates :member_id, :facility_id, :presence => true

  scope :owners, where(:function => "Praxis")
  
  scope :directors, where(:function.matches => "Klinikdirektor%")
end
