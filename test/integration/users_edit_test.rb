require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:atallah)
  end

  test "an unsuccessful edit" do
  	log_in_as(@user)
  	get edit_user_path(@user)
  	assert_template 'users/edit'
  	patch user_path(@user), user: { name: "",
  									email: "invalid@email",
  									password: "doesnt",
  									password_confirmation: "match" }
	assert_template 'users/edit'  									
  end

  test "a successful edit" do
  	log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name: "Atallah Hezbor",
    								email: "changedemail@example.com",
    								password: "",
    								password_confirmation: ""}
	assert_redirected_to @user
	assert !flash.empty?
	@user.reload
	assert_equal @user.name, "Atallah Hezbor"
	assert_equal @user.email, "changedemail@example.com"
  end

  test "a successful edit with a redirect to intended page" do #friendly forwarding
  	get edit_user_path(@user)
  	log_in_as(@user)
	assert_redirected_to edit_user_path(@user)   
    patch user_path(@user), user: { name: "Atallah Hezbor",
    								email: "changedemail@example.com",
    								password: "",
    								password_confirmation: ""}
	assert_redirected_to @user
	assert !flash.empty?
	@user.reload
	assert_equal @user.name, "Atallah Hezbor"
	assert_equal @user.email, "changedemail@example.com"
  assert_equal session[:forwarding_url], nil
  end
end
