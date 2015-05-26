class EquipmentTypesController < ControllerWithAuthentication
  filter_resource_access :collection         => [:index], 
                         :member             => [:destroy, :update],
                         :no_attribute_check => [:index]
  
  layout "default_side_nav"
  
  # GET /equipment_types
  # GET /equipment_types.xml
  def index
    @equipment_types = EquipmentType.all
    @new_equipment_type = EquipmentType.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @equipment_types }
    end
  end
  
  # POST /equipment_types
  # POST /equipment_types.xml
  def create
    respond_to do |format|
      if @equipment_type.save
        format.html { redirect_to(equipment_types_url, :notice => 'Equipment type was successfully created.') }
        format.xml  { render :xml => @equipment_type, :status => :created, :location => @equipment_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @equipment_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /equipment_types/1
  # PUT /equipment_types/1.xml
  def update
    respond_to do |format|
      if @equipment_type.update_attributes(params[:equipment_type])
        format.html { redirect_to(equipment_types_url, :notice => 'Equipment type was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @equipment_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /equipment_types/1
  # DELETE /equipment_types/1.xml
  def destroy
    @equipment_type.destroy

    respond_to do |format|
      format.html { redirect_to(equipment_types_url) }
      format.xml  { head :ok }
    end
  end
end
