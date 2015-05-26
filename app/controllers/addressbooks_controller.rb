class AddressbooksController < ControllerWithAuthentication
  filter_access_to :all

  layout "with_search"
  
  respond_to :html, :xlsx, :json

  before_filter do
    @structure_top_level = OrganizationalUnit.top_level
  end
  
  before_filter do
    breadcrumb t("nav.addressbook"), addressbook_path
  end 

  def show
    if params[:commit] == t("addressbooks.search.export")
      redirect_to addressbook_url(:format => :xlsx, :search => params[:search])
    else
      @search   = Member.addressbook_list.search(params[:search])

      respond_to do |format|
        format.html do
          @members  = @search.relation.page(params[:page]).per(21)
        end
        format.xlsx do
          if permitted_to?(:export, :addressbooks)
            @members  = @search.relation
          else
            send(:render, :text => "You are not allowed to access this action.",
                 :status => :forbidden)
          end
        end
      end
    end
  end

  def autocomplete_personal
    term = "%#{params[:term]}%"
    per_topic = 20

    @members = Member.addressbook.select('distinct first_name, last_name').
                                  where({:first_name.matches => term} |
                                        {:last_name.matches => term}).
                                  limit(per_topic)

    result = @members.map {|m| "#{m.first_name} #{m.last_name}" }

    render :json => result
  end

  def autocomplete_specialization
    term = "%#{params[:term]}%"
    
    @specializations = OrganizationalUnit.select('distinct name').
                                          where(:name.matches => term, 
                                                :tag => "specialization").
                                          limit(20)
      
    result = @specializations.map(&:name)
    
    render :json => result
  end

  def autocomplete_business
    term = "%#{params[:term]}%"
    per_topic = 5 

    names = Facility.distinct_values_for(:name, term, per_topic)

    addresses = []

    [:street1, :street2].each do |street|
      addresses += Address.distinct_values_for(street, term, per_topic)
    end

    render :json => (names + addresses)
  end

  def autocomplete_postal_canton
    term = "#{params[:term]}%"
    per_topic = 10

    postal_codes = Address.distinct_values_for(:postal_code, term, per_topic)
    cantons      = Address.distinct_values_for(:canton, term, per_topic)
    cities       = Address.distinct_values_for(:city, term, per_topic)
    
    render :json => (postal_codes + cities + cantons)
  end

  def autocomplete_equipment
    per_topic = 10
    term = "%#{params[:term]}%"

    kinds = EquipmentType.distinct_values_for(:kind, term, per_topic)

    render :json => kinds
  end

  def autocomplete_function
    per_topic = 5
    term = "%#{params[:term]}%"

    kinds = Designation.distinct_values_for(:kind, term, per_topic)

    organizational_units = OrganizationalUnit.distinct_values_for(:name, term, per_topic)

    render :json => (kinds + organizational_units)

  end
end
