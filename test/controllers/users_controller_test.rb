require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup 
  	@user = users(:atallah)
  	@user2 = users(:elizabeth)
  end


  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edits if not logged in" do
  	get :edit, id: @user
  	assert_not flash.empty?
  	assert_redirected_to login_url
  end

  test "should redirect updates if not logged in" do
  	patch :update, id: @user, user: { name: "foo", email: "bar@baz.com" }
  	assert_not flash.empty?
  	assert_redirected_to login_url
  end

  test "should redirect edits if not own profile" do
  	log_in_as(@user2)
  	get :edit, id: @user
  	assert flash.empty?
  	assert_redirected_to root_path
  end

  test "should redirect updates if not own profile" do
  	log_in_as(@user2)
  	patch :update, id: @user, user: {name: "foo", email: "bar@baz.com"}
  	assert flash.empty?
  	assert_redirected_to root_path
  end

  test "should redirect index if not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should redirect destroy if not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy if not admin" do
    log_in_as(@user2)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

  test "should not allow admin attribute to be editted via the web" do
    log_in_as(@user2)
    assert_not @user2.admin?
    patch :update, id: @user2, user: { password: "password", password_confirmation: "password",
                                        admin: true}
    assert_not @user2.reload.admin?
  end

  test "should redirect following when not logged in" do
    get :following, id: @user
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get :followers, id: @user
    assert_redirected_to login_url
  end

end
