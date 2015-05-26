class FacilitiesController < ControllerWithSearch
  filter_resource_access :collection         => [:index, [:autocomplete_member_with_term_facilities, :show]],
                         :no_attribute_check => [:index, [:autocomplete_member_with_term_facilities, :show]],
                         :additional_member  => {
                           :add_member    => :update,
                           :remove_member => :update,
                         }

  autocomplete_for :member, :with_term, :label => :name

  before_filter :only => [:show, :edit, :update] do
    breadcrumb @facility.description, facility_path(@member)
  end
  
  # GET /facilities
  # GET /facilities.xml
  def index
    @search_facilities = Facility.search(params[:search_facilities])
    @facilities        = @search_facilities.relation.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @facilities }
    end
  end

  # GET /facilities/1
  # GET /facilities/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @facility }
    end
  end

  # GET /facilities/new
  # GET /facilities/new.xml
  def new
    prep_for_editing @facility

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @facility }
    end
  end

  # GET /facilities/1/edit
  def edit
    prep_for_editing @facility
  end

  # POST /facilities
  # POST /facilities.xml
  def create

    respond_to do |format|
      if @facility.save
        format.html { redirect_to(@facility, :notice => 'Facility was successfully created.') }
        format.xml  { render :xml => @facility, :status => :created, :location => @facility }
      else
        prep_for_editing @facility
        format.html { render :action => "new" }
        format.xml  { render :xml => @facility.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /facilities/1
  # PUT /facilities/1.xml
  def update

    respond_to do |format|
      if @facility.update_attributes(params[:facility])
        format.html { redirect_to(@facility, :notice => 'Facility was successfully updated.') }
        format.xml  { head :ok }
      else
        prep_for_editing @facility        
        format.html { render :action => "edit" }
        format.xml  { render :xml => @facility.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /facilities/1
  # DELETE /facilities/1.xml
  def destroy
    if @facility.exam_candidates.any?
      respond_to do |format|
        format.html { redirect_to(@facility, :notice => "Cannot delete! There are exam candidates associated with this facility") }
        format.xml  { head :method_not_allowed }
      end
    else
      destination = if @facility.posts.any?
        @facility.posts.first.member
      else
        addressbook_url  
      end
      @facility.destroy

      respond_to do |format|
        format.html { redirect_to(destination) }
        format.xml  { head :ok }
      end
    end
  end
  
  
  def add_member
    if params[:_autocomplete_new_member].blank?
      return redirect_to(@facility)
    end
    
    member = Member.find(params[:_autocomplete_new_member])
    
    unless member
      render :action => "show", :notice => "Member not found!" 
      return
    end
    
    @facility.members << member
    
    if @facility.save 
      redirect_to(@facility, :notice => 'Member successfully connected.' )
    else 
      render :action => "show", :notice => "Member not connected!" 
    end
  end
  
  def remove_member
    @member = @facility.members.find(params[:member_id])
    
    if @facility.members.delete(@member)
      redirect_to(@facility, :notice => 'Facility successfully disconneced.' )
    else
      render :action => "show", :notice => "Facility not disconnected!" 
    end
  end    
  private
  
  def prep_for_editing(facility)
    facility.phone_numbers.build if facility.phone_numbers.none? { |p| p.new_record? }
    facility.addresses.build if facility.addresses.none? { |a| a.new_record? }    
    facility.equipment.build if facility.equipment.none? { |a| a.new_record? }    
  end
end
