class MembersController < ControllerWithSearch
  skip_before_filter :require_member!, :only => [:not_allowed]

  filter_resource_access  :collection         => [:index, 
                                                  :my_profile, 
                                                  [:welcome, :show], 
                                                  [:autocomplete_facility_with_term, :show]],
                          :no_attribute_check => [:index, :my_profile, :welcome, :autocomplete_facility_with_term],
                          :additional_member  => {
                            :edit_password           => :edit_password,
                            :update_password         => :update_password,
                            :add_facility            => :update,
                            :remove_facility         => :update,
                            :toggle_group_membership => :manage_group_membership,
                            :sign_in_on_behalf       => :sign_in_on_behalf
                          }

  autocomplete_for :facility, :with_term, :label => :description

  before_filter :only => [:show, :edit, :update, :edit_password, :update_password] do
    breadcrumb @member.name, member_path(@member)
  end

  def my_profile
    user = current_member

    redirect_to member_path(user)
  end

  # GET /members
  # GET /members.xml
  def index
    @offset = (params[:offset] || "0").to_i
    @q = params[:q]
    @kind = params[:kind]

    if @q.present? or @kind.present?
      if @q.present?
        constraints = build_constraints(@q)
        @members = Member.where(*constraints).order('first_name ASC').limit(26).offset(@offset)
      else
        @members = Member.scoped
      end
      if @kind.present?
        @members = @members.with_kind(@kind)
      end
    else
      @members = Member.order('first_name ASC').limit(26).offset(@offset)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @members }
    end
  end

  # GET /members/1
  # GET /members/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end

  # GET /members/new
  # GET /members/new.xml
  def new
    prep_for_editing(@member)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @member }
    end
  end

  # GET /members/1/edit
  def edit
    prep_for_editing(@member)
  end

  # POST /members
  # POST /members.xml
  def create

    @member.add_default_groups

    respond_to do |format|
      if @member.save
        format.html { redirect_to(@member, :notice => 'Member was successfully created.') }
        format.xml  { render :xml => @member, :status => :created, :location => @member }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.xml
  def update

    respond_to do |format|
      if @member.update_attributes(params[:member])
        format.html { redirect_to(@member, :notice => 'Member was successfully updated.') }
        format.xml  { head :ok }
      else
        prep_for_editing(@member)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_password

    respond_to do |format|
      if @member.update_attributes(params[:member])
        format.html do
          if session[:redirect_to]
            redirect = session.delete(:redirect_to)
            redirect_to(redirect)
          else
            redirect_to(@member, :notice => 'Member was successfully updated.') 
          end
        end 
        format.xml  { head :ok }
      else
        prep_for_editing(@member)
        format.html { render :action => "edit_password" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.xml
  def destroy
    @member.destroy

    respond_to do |format|
      format.html { redirect_to(members_url) }
      format.xml  { head :ok }
    end
  end

  def toggle_group_membership
    @group = Group.find(params[:group_id])

    if @member.groups.exists?(@group)
      @member.groups.delete @group
    else
      @member.groups << @group
    end

    respond_to do |format|
      if @member.save
        format.html { redirect_to(@member, :notice => 'Member was successfully updated.' )}
        format.xml { head :ok }
      else
        head :internal_server_error
      end
    end
  end

  def add_facility
    if params[:_autocomplete_new_facility].blank?
      return redirect_to @member
    end

    facility = Facility.find(params[:_autocomplete_new_facility])

    render :action => "show", :notice => "Facility not found!" unless facility

    @member.facilities << facility

    if @member.save
      redirect_to(@member, :notice => 'Facility successfully connected.' )
    else
      render :action => "show", :notice => "Facility not connectd!"
    end
  end

  def remove_facility
    @facility = @member.facilities.find(params[:facility_id])

    if @member.facilities.delete(@facility)
      redirect_to(@member, :notice => 'Facility successfully disconnected.' )
    else
      render :action => "show", :notice => "Facility not disconnected!"
    end
  end

  def remove_designation
    @designation = @member.designations.find(params[:designation_id])

    if @member.designations.delete(@designation)
      redirect_to(@member, :notice => 'Designation successfully deleted.' )
    else
      render :action => "show", :notice => "Designation not disconnected!"
    end
  end

  def not_allowed
  end

  def edit_password
  end


  def welcome
    if not params[:password_changed]
      session[:redirect_to] = welcome_members_path(:password_changed => true)
      redirect_to edit_password_member_url(current_member)
    else
      redirect_to(current_member)
    end
  end

  def sign_in_on_behalf
    if @member
      sign_in(:member, @member)
      redirect_to(@member)
    end
  end

  private

  def build_constraints(q)
    clauses = []
    words = {}
    constr =q.strip.split(/\s+/).each_with_index do |w, i|
      w_name = :"q#{i}"
      w_value = "%#{w.downcase}%"

      words[w_name] = w_value

      clauses << <<-QUERY
        (lower(first_name) like :#{w_name}
        or lower(last_name) like :#{w_name}
        or lower(middle_name) like :#{w_name}
        or lower(username) like :#{w_name}
        or lower(email) like :#{w_name})
      QUERY
    end

    [clauses.join(" AND "), words]
  end

  def prep_for_editing(member)
    member.phone_numbers.build if member.phone_numbers.none? { |p| p.new_record? }
    member.addresses.build if member.addresses.empty?
  end
end
