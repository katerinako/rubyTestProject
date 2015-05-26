class ControllerWithAuthentication < ApplicationController
  before_filter :authenticate_member!  
  before_filter :set_member_based_locale
  
  alias_method :current_user, :current_member
  
  def set_member_based_locale
    if current_user
      I18n.locale ||= current_user.language.to_sym || I18.default_locale
    end
    
  end
end
