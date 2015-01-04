class RepostsController < ApplicationController
	before_action :logged_in_user

	def create 
		@micropost = Micropost.find(params[:micropost_id])
		current_user.repost(@micropost)
		respond_to do |format|
          format.html { redirect_to @user }
          format.js
        end
		#redirect_to root_url
	end

	def destroy
		# @micropost = Repost.find(params[:id])
		# current_user.un_repost(@user)
	 #    respond_to do |format|
  #         format.html { redirect_to @user }
  #         format.js
  #   	end
	end

end
