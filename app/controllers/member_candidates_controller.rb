class MemberCreationError < Exception; end

class MemberCandidatesController < CandidatesController
  ACCEPTANCE_STATUSES = {
    :am             => "Ausserordentliches Mitglied (AM)",
    :em             => "Ehrenmitglied (EM)",
    :exam_candidate => "Kandidaten Fachexamen",
    :no_membership  => "Kein Mitglied",
    :km             => "Korrespondierendes Mitglied (KM)",
    :om             => "Ordentliches Mitglied (OM)",
    :pm             => "Passivmitglied (PM)",
    :applied        => "Applied"
  }.with_indifferent_access

  ACCEPTANCE_FILTERS = {:all => "All"}.merge(ACCEPTANCE_STATUSES).map { |k, v| [v, k] }

  MEANS_ACCEPTED = %w(am em km om pm)

  filter_resource_access :collection => [:index, :thank_you],
                         :member => [:determine, :set_status],
                         :no_attribute_check => [:index, :thank_you]

  before_filter :except => [:new, :create] do
    breadcrumb t("nav.membership_application"), member_candidates_path

    if @member_candidate
      breadcrumb @member_candidate.name, member_candidate_path(@member_candidate)
    end
  end

  before_filter :only => [:new, :create] do
    breadcrumb t("member_candidates.new.how_to_become_a_member"), new_member_candidate_path
  end

  before_filter :only => [:determine] do
    breadcrumb "Determine Membership Application Status", determine_member_candidate_path(@member_candidate)
  end

  def index
    @search = MemberCandidate.search(params[:search])
    @member_candidates = @search.relation.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @member_candidates }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member_candidate }
    end
  end

  def new
    build_prototypes
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @member_candidate }
    end
  end

  def edit
    build_prototypes
  end

  def thank_you
    respond_to do |format|
      format.html
    end
  end

  def create
    respond_to do |format|
      @member_candidate.build_cv if @member_candidate.cv.nil?
      if @member_candidate.save

        MemberCandidateMailer.confirmation_email(@member_candidate).deliver
        MemberCandidateMailer.registration_email(@member_candidate).deliver

        format.html { redirect_to thank_you_member_candidates_path }
        format.xml  { render :xml => @member_candidate, :status => :created, :location => @member_candidate }
      else
        build_prototypes
        format.html { render :action => "new" }
        format.xml  { render :xml => @member_candidate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      @member_candidate.build_cv if @member_candidate.cv.nil?
      if @member_candidate.update_attributes(params[:member_candidate])
        format.html { redirect_to(@member_candidate, :notice => 'Member candidate was successfully updated.') }
        format.xml  { head :ok }
      else
        build_prototypes
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member_candidate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @member_candidate.destroy

    respond_to do |format|
      format.html { redirect_to(member_candidates_url) }
      format.xml  { head :ok }
    end
  end

  def determine
    respond_to do |format|
      format.html
    end
  end

  def set_status
    respond_to do |format|
      if change_status_and_convert_to_member

        if MEANS_ACCEPTED.include?(@member_candidate.acceptance_status.to_s)
          @member.make_password_token!
          MemberCandidateMailer.accepted_email(@member_candidate, @member).deliver
        else
          MemberCandidateMailer.rejected_email(@member_candidate, @member).deliver
        end

        format.html { redirect_to(@member_candidate, :notice => 'Acceptance status updated successfully.') }
        format.xml { head :ok }
      else
        format.html { render :action => "determine" }
        format.xml { render :xml => @member_candidate.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def change_status_and_convert_to_member
    ok = false
    @member_candidate.transaction do
      ok = @member_candidate.update_attributes(params[:member_candidate])

      if ok and MEANS_ACCEPTED.include?(@member_candidate.acceptance_status.to_s)
        @member = @member_candidate.to_member
        if @member.valid?
          ok &= @member.save
        else
          raise MemberCreationError, "Could not create member object"
        end
      end
    end
  rescue MemberCreationError => e
    false
  else
    ok
  end

  def build_prototypes
    @member_candidate.build_address if @member_candidate.address.nil?
    @member_candidate.build_phone_number if @member_candidate.phone_number.nil?
    @member_candidate.build_cv if @member_candidate.cv.nil?
    @member_candidate.build_photo if @member_candidate.photo.nil?
    (2 - @member_candidate.recommendation_letters.to_a.count).times do
      @member_candidate.recommendation_letters.build
    end
    (2 - @member_candidate.certifications.to_a.count).times do
      @member_candidate.certifications.build
    end
    @member_candidate.internships.build
    @member_candidate.places_of_work.build
  end
end
