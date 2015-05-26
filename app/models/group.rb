class Group < ActiveRecord::Base
  has_and_belongs_to_many :members
  
  validates :name, :presence => true
  validates :code, :presence => true, :uniqueness => true
  
  default_scope order(:name)

  def self.all_user_defined
    where(:system => false).order('name')
  end
  
  def self.all_system
    where(:system => true).order('name')
  end
  
  def self.all
    all_system + all_user_defined
  end
  
  def self.with_code(code) 
    where(:code => code).first
  end
  
  def self.sgdv_members
    with_code(:"sgdv-member")
  end
end
