module ExamCandidatesHelper
  def possible_exams
    Exam.available_for_application + (@exam_candidate.exam ? [@exam_candidate.exam] : [])
  end
  
  def possible_clinics
    Facility.where(:type_of_education.in => [:A, :B, :C]).order(:name) 
  end
  
  def format_experience(number_of_months)
    if number_of_months > 0
      number_to_human(number_of_months, :precision => 0, :significant => false)
    else
      "None"
    end
  end
    
end
