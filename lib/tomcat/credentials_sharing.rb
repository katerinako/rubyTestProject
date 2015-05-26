require 'java'

puts "------------------------ adding warden strategy"

Warden::Strategies.add(:auto_login) do 

  def logger; Rails.logger; end
  
  def shared_context
    servlet_context = env['java.servlet_context']
    return nil unless servlet_context
    
    shared_context = servlet_context.get_context("/shared")
    
    logger.debug("Autologin: shared_context found: #{shared_context}")
    
    shared_context
  end

  def shared_context_object
    shared_ctx = shared_context
    
    shared_ctx ? shared_ctx.get_attribute("data") : nil
  end
  
  def servlet_request
    env['java.servlet_request']
  end
  
  def shared_username
    data = shared_context_object
    request = servlet_request

    logger.debug("Autlogin request = #{request}, data = #{data.inspect}")
    return nil unless request

    session = servlet_request.get_session(true)

    logger.debug("Autlogin request = #{request}, data = #{data}, session = #{session}")
    
    data.get(session.id) if (data && session)
  end

  def valid? 
    logger.info("Trying auto_login strategy")
    username = shared_username
    if username
      logger.info("Shared login data detected for user: #{username}")
    end
    shared_username  
  end 

  def authenticate! 
    username = shared_username

    user = Member.find_by_username(username)
    
    if user
      logger.info("Transfering login from Website to backend for user #{username}")
      success!(user)
    else
      logger.error("User #{username} found in shared context but user couldn't be loaded")
    end
  end 
end

# Transfer the user back to the  shared context
Warden::Manager.after_authentication do |user, auth, opts|
  logger = Rails.logger
  
  logger.info("Autologin: user logged in, trying to set shared credentials")
  
  servlet_context = auth.env['java.servlet_context']
  shared_context = servlet_context.nil? ? nil : servlet_context.get_context("/shared")
  
  request =  auth.env['java.servlet_request']
  session = request.nil? ? nil : request.get_session(true)

  if shared_context and session
    logger.info("Autologin: environment correct (shared context, session)")
    data = shared_context.get_attribute("data")
    
    unless data
      data = java.util.HashMap.new
      shared_context.set_attribute("data")
    end
    
    data.put(session.id, user.username)
    
    logger.info("Autologin: success")
  end
  
  
end

# Logout the user from the shared context as well
Warden::Manager.before_logout do |user, auth, opts|
  
  logger = Rails.logger
  
  logger.info("Autologin: user loggin out, trying to unset shared credentials")

  servlet_context = auth.env['java.servlet_context']
  shared_context = servlet_context.nil? ? nil : servlet_context.get_context("/shared")
  
  request =  auth.env['java.servlet_request']
  session = request.nil? ? nil : request.get_session(true)
  
  if shared_context and session
    logger.info("Autologin: environment correct (shared context, session)")
    
    data = shared_context.get_attribute("data")
    
    if data
      data.remove(session.id)
      
      logger.info("Autologin: success")
    end
  end
end
