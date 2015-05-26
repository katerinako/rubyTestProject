class MembershipsController < ControllerWithAuthentication
  filter_resource_access :collection         => [[:autocomplete_member_with_term, :show]],
                         :no_attribute_check => [:autocomplete_member_with_term]
  
  autocomplete_for :member, :with_term, :label => :name

  sets_content_for_back
  
  layout "default_side_nav"
  
  before_filter :only => [:show] do 
    breadcrumb "Members", members_path
    breadcrumb @membership.member.name, member_path(@membership.member)
    breadcrumb @membership.description
  end
  
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end 
  end
  
  # GET /memberships/new
  # GET /memberships/new.xml
  def new    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /memberships/1/edit
  def edit
  end

  # POST /memberships
  # POST /memberships.xml
  def create
    respond_to do |format|
      if @membership.save
        format.html { redirect_to(@destination, :notice => 'Membership was successfully created.') }
        format.xml  { render :xml => @membership, :status => :created, :location => @membership }
      else
        puts "errors"
        format.html { render :action => "new" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.xml
  def update
    respond_to do |format|
      puts "DEST: #{@destination}"
      if @membership.update_attributes(params[:membership])
        format.html { redirect_to(@destination, :notice => 'Membership was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.xml
  def destroy
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to(@destination) }
      format.xml  { head :ok }
    end
  end
  
  
  def new_membership_from_params
    @membership = Membership.new(params[:membership])
    @membership.member_id = params[:member_id] unless @membership.member
    
    puts "Membership member: #{@membership.member}"
  end
end
