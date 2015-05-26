
class ExamCandidatesController < ControllerWithAuthentication
  skip_before_filter :authenticate_member!, :only => [:new, :create, :thank_you, :no_exams_available]

  filter_resource_access :collection         => [:index, :no_exams_available, :thank_you],
                         :additional_member  => [:approve_by_sgdv, :approve_by_clinic_director],
                         :no_attribute_check => [:index, :no_exams_available, :thank_you]

  before_filter do
     breadcrumb "Exams", exams_path
     if @exam_candidate and @exam_candidate.exam and not @exam_candidate.new_record?
       breadcrumb @exam_candidate.exam.to_s, exam_path(@exam_candidate.exam)
     end
  end
  before_filter :except => [:index, :new, :create, :thank_you] do
    breadcrumb @exam_candidate.name, exam_candidate_path(@exam_candidate)
  end

  # GET /exam_candidates
  # GET /exam_candidates.xml
  def index
    redirect_to exams_path
  end

  # GET /exam_candidates/1
  # GET /exam_candidates/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exam_candidate }
    end
  end

  def no_exams_available
    respond_to do |format|
      format.html { render "no_exams_available" }
      format.xml { head :not_found }
    end
  end

  # GET /exam_candidates/new
  # GET /exam_candidates/new.xml
  def new
    unless Exam.available_for_application.empty?
      @exam_candidate = ExamCandidate.new
      @exam_candidate.attachments.build
      @exam_candidate.internships.build
      @exam_candidate.build_address


      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @exam_candidate }
      end
    else
      no_exams_available
    end
  end

  # GET /exam_candidates/1/edit
  def edit
    @exam_candidate.attachments.build
    @exam_candidate.internships.build
    @exam_candidate.build_address if @exam_candidate.address.blank?
  end

  # POST /exam_candidates
  # POST /exam_candidates.xml
  def create
    respond_to do |format|
      if @exam_candidate.save

        # send notifications
        ExamNotifications.application_confirmed(@exam_candidate).deliver

        recipient = @exam_candidate.current_clinic.director ||
                      Rails.application.config.exams_email
        ExamNotifications.ask_for_confirmation(
          @exam_candidate,
          recipient,
          [OrganizationalUnit.admin, OrganizationalUnit.secretary].reject(&:nil?)).deliver

        format.html { redirect_to thank_you_exam_candidates_path }
        format.xml  { render :xml => @exam_candidate, :status => :created, :location => @exam_candidate }
      else
        @exam_candidate.attachments.build
        @exam_candidate.internships.build

        format.html { render :action => "new" }
        format.xml  { render :xml => @exam_candidate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def thank_you
    respond_to do |format|
      format.html
    end
  end

  # PUT /exam_candidates/1
  # PUT /exam_candidates/1.xml
  def update
    respond_to do |format|
      if @exam_candidate.update_attributes(params[:exam_candidate])
        format.html { redirect_to(@exam_candidate, :notice => 'Candidate was successfully updated.') }
        format.xml  { head :ok }
      else
        @exam_candidate.attachments.build
        @exam_candidate.internships.build
        # @exam_candidate.build_address

        format.html { render :action => "edit" }
        format.xml  { render :xml => @exam_candidate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exam_candidates/1
  # DELETE /exam_candidates/1.xml
  def destroy
    @exam_candidate.destroy

    respond_to do |format|
      format.html { redirect_to(candidates_url) }
      format.xml  { head :ok }
    end
  end

  def approve_by_clinic_director
    @exam_candidate.approved_by_clinic_director = true
    @exam_candidate.save

    ExamNotifications.ask_for_confirmation_sgdv(
      @exam_candidate,
      Rails.application.config.exams_email,
      [OrganizationalUnit.admin, OrganizationalUnit.secretary].reject(&:nil?)).deliver

    respond_to do |format|
      format.html { redirect_to(@exam_candidate, :notice => 'Candidate has been APPROVED!')}
      format.xml {head :ok}
    end
  end

  def approve_by_sgdv
    @exam_candidate.approved_by_sgdv = true
    @exam_candidate.save

    ExamNotifications.application_approved(@exam_candidate).deliver

    respond_to do |format|
      format.html { redirect_to(@exam_candidate, :notice => 'Candidate has been APPROVED!')}
      format.xml {head :ok}
    end
  end

end
