class Equipment < ActiveRecord::Base
  belongs_to :equipment_type
  belongs_to :facility
  
  validates :description, :presence => true
  
end
