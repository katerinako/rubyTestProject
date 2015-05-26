class ApplicationMailer < ActionMailer::Base

	protected

	# selects a locale for the duration of the block
	# provided to the method
  def using_locale(l)
    old_locale = I18n.locale
    I18n.locale = l
  
  	begin
  		old_locale = I18n.locale
  		I18n.locale = l

	    yield
	  ensure
	    I18n.locale = old_locale  
   	end
  end
end