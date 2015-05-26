class PostsController < ControllerWithSearch
  filter_resource_access  :collection         => [[:autocomplete_member_with_term, :show],
                                                  [:autocomplete_facility_with_term, :show],
                                                  [:new_post_with_facility, :new]],

                          :no_attribute_check => [:autocomplete_member_with_term,                                                                                                     
                                                  :autocomplete_facility_with_term],

                           :additional_new     => [:new_post_with_facility]
  
  autocomplete_for :member, :with_term, :label => :name
  autocomplete_for :facility, :with_term, :label => :description

  def default_url_options(options = {})
    super(options).merge(params.slice(:coming_from, :facility_id, :member_id, :with_facility))
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @coming_from = params[:coming_from]
    
    @post.member_id = params[:member_id]
    @post.facility_id = params[:facility_id]
    
    @destination = case @coming_from
    when 'member'
      @post.member
    when 'facility'
      @post.facility
    else
      @post.member
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  def new_post_with_facility
    @post.member_id = params[:member_id]
    @post.function = "Praxis"

    prep_for_editing(@post)
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @post }
    end
  end
  
  # GET /posts/1/edit
  def edit
    @coming_from = params[:coming_from]
    @destination = case @coming_from
    when 'member'
      @post.member
    when 'facility'
      @post.facility
    else 
      @post.member
    end
  end

  def edit_with_facility
    @coming_from = :member
    @destination = @post.member
  end

  # POST /posts
  # POST /posts.xml
  def create
    @coming_from = params[:coming_from]
    @destination = destination
    
    respond_to do |format|
      Post.transaction do 
        if params[:with_facility]
          facility_saved = @post.facility.save
          @post.facility_id = @post.facility.id
        else
        facility_saved = true
        end

        if facility_saved and @post.save
          format.html { redirect_to(@destination, :notice => 'Post was successfully created.') }
          format.xml  { render :xml => @post, :status => :created, :location => @post }
        else
          if params[:with_facility]
            prep_for_editing(@post)
            format.html { render :action => "new_post_with_facility" }
          else
            format.html { render :action => "new" }
          end
          format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @coming_from = params[:coming_from]
    @destination = destination
    
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html do
          redirect_to(@destination, :notice => 'Post was successfully updated.') 
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post.destroy
    back_to = params[:back_to] || posts_url
    respond_to do |format|
      format.html { redirect_to(back_to) }
      format.xml  { head :ok }
    end
  end
  
  private 
  
  def destination 
    case @coming_from
    when 'member'
      destination = @post.member
    when 'facility'
      destination = @post.facility
    else
      destination = @post.member
    end
  end
  
  private
  
  def prep_for_editing(post)
    post.build_facility if post.facility.nil?
    post.facility.kind = :praxis

    facility = post.facility

    facility.phone_numbers.build if facility.phone_numbers.none? { |p| p.new_record? }
    facility.addresses.build if facility.addresses.none? { |a| a.new_record? }    
    facility.equipment.build if facility.equipment.none? { |a| a.new_record? }    

  end
  
end
