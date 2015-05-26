class DesignationsController < ControllerWithAuthentication
  filter_resource_access  :collection         => [[:autocomplete_member_with_term, :show],
                                                  [:autocomplete_organizational_unit_with_term, :show]],
                          :no_attribute_check => [:autocomplete_member_with_term,                                                                                                     
                                                  :autocomplete_organizational_unit_with_term]
  
  autocomplete_for :member, :with_term, :label => :name
  autocomplete_for :organizational_unit, :with_term, :label => :name

  layout "default_side_nav"

  # GET /designations/new
  # GET /designations/new.xml
  def new
    @coming_from = params[:coming_from]
    
    @designation.member_id = params[:member_id]
    @designation.organizational_unit_id = params[:organizational_unit_id]
    
    @destination = case @coming_from
    when 'member'
      @designation.member
    when 'organizational_unit'
      @designation.organizational_unit
    else
      @designation.member
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @designation }
    end
  end

  # GET /designations/1/edit
  def edit
    @coming_from = params[:coming_from]
    @destination = case @coming_from
    when 'member'
      @designation.member
    when 'organizational_unit'
      @designation.organizational_unit
    else 
      @designation.member
    end
  end

  # POST /designations
  # POST /designations.xml
  def create
    @coming_from = params[:coming_from]
    @destination = destination
    
    respond_to do |format|
      if @designation.save
        format.html { redirect_to(@destination, :notice => 'Designation was successfully created.') }
        format.xml  { render :xml => @designation, :status => :created, :location => @designation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @designation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /designations/1
  # PUT /designations/1.xml
  def update
    @coming_from = params[:coming_from]
    @destination = destination
    
    respond_to do |format|
      if @designation.update_attributes(params[:designation])
        format.html do
          redirect_to(@destination, :notice => 'Designation was successfully updated.') 
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @designation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /designations/1
  # DELETE /designations/1.xml
  def destroy
    @designation.destroy

    respond_to do |format|
      format.html { redirect_to(designations_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def destination 
    case @coming_from
    when 'member'
      destination = @designation.member
    when 'organizational_unit'
      destination = @designation.organizational_unit
    else
      destination = @designation.member
    end
  end
  
  
end
