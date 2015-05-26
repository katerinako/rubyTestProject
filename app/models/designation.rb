class Designation < ActiveRecord::Base
  extend DistinctFields

  belongs_to :member
  belongs_to :organizational_unit
  
  validates :from_date, :kind, :member_id, :organizational_unit_id, :presence => true
  
  default_scope includes(:member).order("members.last_name")

  scope :current, lambda { 
    now = Date.today
    where(:from_date.lte % now & (:to_date.gte % now | :to_date.eq % nil))
  }
  
  scope :past, lambda {
    now = Date.today
    where(:to_date.not_eq => nil, :to_date.lt => now)
  }
  
end
