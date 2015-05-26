class ExamsController < ControllerWithAuthentication
  filter_resource_access :collection => [:index], :no_attribute_check => [:index]


  before_filter { breadcrumb "Exams", exams_path }
  
  before_filter :except => [:index, :new, :create] do 
    breadcrumb @exam.to_s, exam_path(@exam)
  end
  
  # GET /exams
  # GET /exams.xml
  def index
    @exams = Exam.order("date_of_exam DESC")

    respond_to do |format|
      format.html # index.html.erfvb
      format.xml  { render :xml => @exams }
    end
  end

  CANDIDATE_FILTERS = {
    :all => :exam_candidates,
    :director_approval => :exam_candidates_needing_director_approval,
    :sgdv_aproval => :exam_candidates_needing_sgdv_approval,
    :results => :exam_candidates_with_results
  }

  def default_filter(exam)
    case
    when exam.past?
      :results
    else
      :all
    end
  end
  
  # GET /exams/1
  # GET /exams/1.xml
  def show
    @candidate_filter = (params[:candidate_filter] || default_filter(@exam)).to_sym
    @selected_candidates = @exam.send(CANDIDATE_FILTERS[@candidate_filter])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exam }
    end
  end

  # GET /exams/new
  # GET /exams/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exam }
    end
  end

  # GET /exams/1/edit
  def edit
    @exam = Exam.find(params[:id])
  end

  # POST /exams
  # POST /exams.xml
  def create
    respond_to do |format|
      if @exam.save
        format.html { redirect_to(@exam, :notice => 'Exam was successfully created.') }
        format.xml  { render :xml => @exam, :status => :created, :location => @exam }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exam.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exams/1
  # PUT /exams/1.xml
  def update
    respond_to do |format|
      if @exam.update_attributes(params[:exam])
        format.html { redirect_to(@exam, :notice => 'Exam was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exam.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exams/1
  # DELETE /exams/1.xml
  def destroy
    if @exam.exam_candidates.empty?
      @exam.destroy
      respond_to do |format|
        format.html { redirect_to(exams_url) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to(@exam, :notice => "Cannot delete! There are exam candidates associated with this exam.") }
        format.xml  { head :method_not_allowed }
      end
    end
  end
end
