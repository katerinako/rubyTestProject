class Invoice < ActiveRecord::Base
  belongs_to :membership
  
  validates_presence_of :period_from_date, :period_to_date, :fee_amount  
  validates :period_from_date, :date => true
  validates :period_to_date, :date => {:after => :period_from_date}
  validates_numericality_of :fee_amount

  default_scope order(:period_to_date.desc, :period_from_date.desc)
  
  scope :as_of_date, lambda { |date|  
    where(:period_from_date.lte => date, :period_to_date.gte => date)
  }
  
  scope :current, as_of_date(Date.today)
  
end
