class ExamCandidate < Candidate
  default_scope :include => :result

  validates_acceptance_of :application_terms
  validates_presence_of :current_clinic_id, :exam_id,
                        :language, :place_of_medical_exam

  validates :months_of_experience, :numericality => {:only_integer => true}, :presence => true

  belongs_to :exam

  has_one :result, :autosave => true

  belongs_to :current_clinic, :class_name => "Facility"

  def status
    case
    when (not approved_by_clinic_director?)
      :clinic_director_approval_pending
    when (not approved_by_sgdv?)
      :sgdv_approval_pending
    when (result && result.status == :success)
      :successful_exam
    when (result && result.status == :failure)
      :failed_exam
    when (result && result.status == :pending)
      :pending_results
    else
      :pending_results
    end
  end

end
