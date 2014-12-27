class SessionsController < ApplicationController

  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		log_in(user) #using the session helper
      redirect_to user #the users profile page
  	else
  		flash.now[:danger] = "Invalid email or password"
  		render 'new'
	end
  end

  def destroy

  end

end
