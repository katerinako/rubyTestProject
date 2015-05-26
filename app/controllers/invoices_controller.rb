class InvoicesController < ControllerWithAuthentication
  filter_resource_access :nested_in => :memberships
  
  layout "default_side_nav"

  before_filter do 
    breadcrumb "Members", members_path
    breadcrumb @membership.member.name, member_path(@membership.member)
    breadcrumb "Membership Fees: #{@membership.membership_category.name}"
  end  
  
  before_filter :only => [:show, :edit, :update] do
    breadcrumb "Fee for #{@membership.membership_category.name}"
  end
  
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invoice }
    end
  end

  # GET /invoices/new
  # GET /invoices/new.xml
  def new
    unless @membership.invoices.empty?
      start = 1.day.since(@membership.invoices.order(:period_to_date.desc).first.period_to_date)
    else
      start = Date.today
    end
    
    category = @membership.membership_category
    @invoice = @membership.invoices.build(
      :fee_amount => category.fee,
      :period_from_date => start,
      :period_to_date => category.fee_period.months.since(start),
      :invoice_sent => true)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invoice }
    end
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  # POST /invoices.xml
  def create
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to(@membership, :notice => 'Invoice successfully created.') }
        format.xml  { render :xml => @invoice, :status => :created, :location => @invoice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invoices/1
  # PUT /invoices/1.xml
  def update
    respond_to do |format|
      if @invoice.update_attributes(params[:invoice])
        format.html { redirect_to(@membership, :notice => 'Invoice was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.xml
  def destroy
    @invoice.destroy

    respond_to do |format|
      format.html { redirect_to(@membership) }
      format.xml  { head :ok }
    end
  end
  
  def mark_sent
    @invoice.invoice_sent = true
    save_and_respond
  end
  
  def mark_paid
    @invoice.invoice_paid = true
    save_and_respond
  end
  
  private
  
  def save_and_respond
    respond_to do |format|
      if @invoice.save 
        format.html { redirect_to(@membership, :notice => 'Invoice was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@membership, :notice => 'Invoice was NOT updated.') }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end
end
