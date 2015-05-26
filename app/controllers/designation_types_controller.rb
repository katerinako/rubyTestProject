class DesignationTypesController < ControllerWithAuthentication
  filter_resource_access :collection         => [:index], 
                         :member             => [:destroy],
                         :no_attribute_check => [:index]

  layout "default_side_nav"
                          
  # GET /designation_types
  # GET /designation_types.xml
  def index
    @designation_types = DesignationType.designation_types
    @new_designation_type = DesignationType.new(:grouping => :designation)

    @functions = DesignationType.functions
    @new_function = DesignationType.new(:grouping => :function)

    @praxis_functions = DesignationType.praxis_functions
    @new_praxis_function = DesignationType.new(:grouping => :praxis_function)

    @membership_nominations = DesignationType.membership_nominations
    @new_membership_nomination = DesignationType.new(:grouping => :membership_nomination)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @designation_types }
    end
  end


  # POST /designation_types
  # POST /designation_types.xml
  def create
    respond_to do |format|
      if @designation_type.save
        format.html { redirect_to(designation_types_path, :notice => 'Designation type was successfully created.') }
        format.xml  { render :xml => @designation_type, :status => :created, :location => @designation_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @designation_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /designation_types/1
  # DELETE /designation_types/1.xml
  def destroy
    @designation_type.destroy

    respond_to do |format|
      format.html { redirect_to(designation_types_url) }
      format.xml  { head :ok }
    end
  end
end
