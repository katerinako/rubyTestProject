class CandidatesController < ControllerWithAuthentication
  skip_before_filter :authenticate_member!, :only => [:new, :create, :thank_you]

  def thank_you
    respond_to do |format|
      format.html
    end
  end
end
