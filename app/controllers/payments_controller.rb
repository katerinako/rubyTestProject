class PaymentsController < ControllerWithAuthentication
  filter_access_to :all, :attribute_check => false

  FILTERS = {
    :invoice_due => "Memberships For Which Invoice Needs To Be Sent",
    :payment_due => "Memberships For Which Payments Are Due",
    :invoice_soon => "Memberships For Which Invoice Should be Sent Soon"
  }

  def index
    params[:search] ||= {}
    params[:search][:with_status] ||= :invoice_due
    @search = Membership.search(params[:search])
    @memberships = @search.relation.page(params[:page])
  end
end
