class MembershipCategory < ActiveRecord::Base
  KINDS = ["SGDV", "Dermarena", "Other"]
  
  validates :name,       :presence => true
  validates :kind,       :presence => true, :inclusion => KINDS
  validates :fee,        :numericality => true
  validates :fee_period, :numericality => {:only_integer => true}
  
  has_many :memberships, :dependent => :destroy, :autosave => true
  
  default_scope order(:kind, :name)
end

