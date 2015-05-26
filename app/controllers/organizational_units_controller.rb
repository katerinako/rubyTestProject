class OrganizationalUnitsController < ControllerWithAuthentication
  filter_resource_access :collection         => [:index], 
                         :additional_member  => [:remove_designation],
                         :no_attribute_check => [:index]
                         
  before_filter :setup_layout

  before_filter do
    breadcrumb t("nav.addressbook"), addressbook_path
  end
  
  before_filter :only => [:show, :edit, :update] do
    path = []
    current = @organizational_unit
    
    while current
      path << current
      current = current.parent
    end
    
    path.reverse.each { |n| breadcrumb n.name, organizational_unit_path(n) }
  end
  
  # GET /organizational_units
  # GET /organizational_units.xml
  def index    
    @organizational_units = @top_level
    
    unless @top_level.empty?
      redirect_to @top_level.first
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @organizational_units }
      end
    end
    
  end

  # GET /organizational_units/1
  # GET /organizational_units/1.xml
  def show
    @title = @organizational_unit.name

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organizational_unit }
    end
  end

  # GET /organizational_units/new
  # GET /organizational_units/new.xml
  def new
    if params[:parent_id] 
      @organizational_unit.parent = OrganizationalUnit.find(params[:parent_id])
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organizational_unit }
    end
  end

  # GET /organizational_units/1/edit
  def edit
  end

  # POST /organizational_units
  # POST /organizational_units.xml
  def create
    respond_to do |format|
      if @organizational_unit.save
        format.html {
           redirect_to(@organizational_unit.parent.nil? ? @organizational_unit : @organizational_unit.parent, 
                       :notice => 'Organizational unit was successfully created.') 
        }
        format.xml  { render :xml => @organizational_unit, :status => :created, :location => @organizational_unit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @organizational_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organizational_units/1
  # PUT /organizational_units/1.xml
  def update
    respond_to do |format|
      if @organizational_unit.update_attributes(params[:organizational_unit])
        format.html { 
          redirect_to(@organizational_unit.parent.nil? ? @organizational_unit : @organizational_unit.parent, 
                      :notice => 'Organizational unit was successfully updated.') 
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organizational_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organizational_units/1
  # DELETE /organizational_units/1.xml
  def destroy
    parent = @organizational_unit.parent
    
    @organizational_unit.destroy
    
    respond_to do |format|
      format.html { redirect_to(parent || organizational_units_url) }
      format.xml  { head :ok }
    end
  end

  def remove_designation
    @designation = @organizational_unit.designations.find(params[:designation_id])
    
    if @organizational_unit.designations.delete(@designation)
      redirect_to(@organizational_unit, :notice => 'Designation successfully deleted.' )
    else
      render :action => "show", :notice => "Designation not disconnected!" 
    end
  end
    
  protected

  def setup_layout
    @top_level = OrganizationalUnit.top_level
  end
  
end
