class Result < ActiveRecord::Base
  STATUSES = [:pending, :success, :failure]
  belongs_to :exam_candidate

  def status
    (read_attribute(:status) || :pending).to_sym
  end

  before_validation do
    self.status ||= :pending
  end

end
