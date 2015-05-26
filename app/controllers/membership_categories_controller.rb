class MembershipCategoriesController < ControllerWithAuthentication
  filter_resource_access :collection         => [:index], 
                         :no_attribute_check => [:index]
  
  layout "default_side_nav"

  
  # GET /membership_categories
  # GET /membership_categories.xml
  def index
    @membership_categories = MembershipCategory.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @membership_categories }
    end
  end

  # GET /membership_categories/1
  # GET /membership_categories/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @membership_category }
    end
  end

  # GET /membership_categories/new
  # GET /membership_categories/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership_category }
    end
  end

  # GET /membership_categories/1/edit
  def edit
  end

  # POST /membership_categories
  # POST /membership_categories.xml
  def create
    respond_to do |format|
      if @membership_category.save
        format.html { redirect_to(@membership_category, :notice => 'Membership category was successfully created.') }
        format.xml  { render :xml => @membership_category, :status => :created, :location => @membership_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @membership_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /membership_categories/1
  # PUT /membership_categories/1.xml
  def update
    respond_to do |format|
      if @membership_category.update_attributes(params[:membership_category])
        format.html { redirect_to(@membership_category, :notice => 'Membership category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /membership_categories/1
  # DELETE /membership_categories/1.xml
  def destroy
    @membership_category.destroy

    respond_to do |format|
      format.html { redirect_to(membership_categories_url) }
      format.xml  { head :ok }
    end
  end
end
