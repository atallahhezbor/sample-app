module SessionsHelper

	def log_in(user)
	  session[:user_id] = user.id
	end

	# Assign the current user if it hasn't been (nil)
	# and return it
	def current_user
      @current_user ||= User.find_by(id: session[:user_id])
  	end

  	# Returns true if the user is logged in
  	def logged_in?
  	  !current_user.nil?
  	end
end
