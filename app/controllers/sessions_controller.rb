class SessionsController < ApplicationController

  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		log_in(user) #using the session helper
      # store a cookie if the remember me checkbox is checked
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or user #redirect to the user page unless the is a stored forwarding location
  	else
  		flash.now[:danger] = "Invalid email or password"
  		render 'new'
	end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

end
