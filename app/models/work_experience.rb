class WorkExperience < ActiveRecord::Base
  validates_presence_of :date_from, :date_to, :clinic
  
  validates :date_to, :date => {:after => :date_from}

  belongs_to :candidate
  
  def months
    (date_to.year * 12 + date_to.month) - (date_from.year * 12 + date_from.month - 1)
  end
  
end
