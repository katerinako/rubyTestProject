class ResultsController < ControllerWithAuthentication
  filter_resource_access :nested_in => :exam_candidates

  before_filter do
     breadcrumb "Exams", exams_path
     if @exam_candidate and @exam_candidate.exam
       breadcrumb @exam_candidate.exam.to_s, exam_path(@exam_candidate.exam)
     end

     if @exam_candidate
       breadcrumb @exam_candidate.name, exam_candidate_path(@exam_candidate)
     end
  end

  # GET /results/1
  # GET /results/1.xml
  def show
    @exam_candidate = ExamCandidate.find(params[:exam_candidate_id])
    @result = @exam_candidate.result

    respond_to do |format|
      format.html do
        redirect_to @exam_candidate if not @result
        # otherwise show.html.erb
      end
      format.xml  { render :xml => @result }
    end
  end

  # GET /results/new
  # GET /results/new.xml
  def new

    puts "Result: #{@result}"
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @result }
    end
  end

  # GET /results/1/edit
  def edit

  end

  # POST /results
  # POST /results.xml
  def create
    respond_to do |format|
      if @result.save
        format.html { redirect_to(@exam_candidate, :notice => 'Result was successfully created.') }
        format.xml  { render :xml => @result, :status => :created, :location => @result }
      else
        format.html { puts "in format html"; render :action => "new" }
        format.xml  { render :xml => @result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /results/1
  # PUT /results/1.xml
  def update
    respond_to do |format|
      if @result.update_attributes(params[:result])
        format.html { redirect_to(@exam_candidate, :notice => 'Result was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.xml
  def destroy
    @result.destroy

    respond_to do |format|
      format.html { redirect_to(results_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def load_result
    puts "In load result"
    @result = @exam_candidate.result
  end

  def new_result_for_collection
    @result = @exam_candidate.build_result
  end

  def new_result_from_params
    @result = @exam_candidate.build_result(params[:result])
  end

end
