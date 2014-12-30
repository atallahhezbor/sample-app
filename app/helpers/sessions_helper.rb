module SessionsHelper

	def log_in(user)
	  session[:user_id] = user.id
	end

	def log_out
		forget(current_user) #delete the cookies for the user
		session.delete(:user_id)
		@current_user = nil
	end


	# Assign the current user if it hasn't been (nil) and return it
	def current_user
	  if session[:user_id]	#if a session exists, use that
    	@current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id] #otherwise use a cookie if it exists
     	user = User.find_by(id: cookies.signed[:user_id]) #find the corresponding user
     	if user && user.authenticated?(:remember, cookies[:remember_token]) #if found and token mathches, login and return
     		log_in user 
     		@current_user = user
     	end
    end
  end

  # Returns true if the user is logged in
  def logged_in?
    !current_user.nil?
  end

  # Remember a user in a persistent session
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # deletes the cookies for the persistent session
  def forget(user)
	 user.forget
	 cookies.delete(:user_id)
	 cookies.delete(:remember_token)
  end

  # Returns true if the passed user is the currently logged in user
  def current_user?(user)
    current_user == user
  end

  # redirects to the stored url or to the default
  def redirect_back_or(default)
    redirect_to session[:forwarding_url] || default
    session.delete(:forwarding_url)
  end

  # Stores the url currently being accessed 
  # so that it can be redirected to in the event of an error
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

end
