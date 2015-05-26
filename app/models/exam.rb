class Exam < ActiveRecord::Base
  validates_presence_of :name, :location
  validates_presence_of :date_of_exam, :start_time, :end_time, :application_deadline
  
  validates :application_deadline,  :date => {:before_or_equal_to => :date_of_exam}

  has_many :exam_candidates, :dependent => :destroy

  def feedback_date
    application_deadline.advance :months => 1
  end
  
  def applications_allowed?
    application_deadline.future?
  end

  def past?
    date_of_exam.past?
  end

  def exam_candidates_needing_director_approval
    exam_candidates.select {|c| c.status == :clinic_director_approval_pending }
  end

  def exam_candidates_needing_sgdv_approval
    exam_candidates.select {|c| c.status = :sgdv_approval_pending }
  end

  def exam_candidates_with_results
    exam_candidates # IMPLEMENT
  end


  def to_s
    "#{name} (#{date_of_exam}, #{location})"
  end

  def self.available_for_application
    all.select {|e| e.applications_allowed?}
  end
  
end
