class ControllerWithSearch < ControllerWithAuthentication
  layout "with_search"
  
  before_filter do
    @structure_top_level = OrganizationalUnit.top_level
  end  

   before_filter do
    breadcrumb t("nav.addressbook"), addressbook_path
  end 

  before_filter do
    @search   = Member.addressbook_list.search(params[:search])
  end 

end