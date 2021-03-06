require 'test_helper'

class UserTest < ActiveSupport::TestCase

	def setup
		@user = User.new(name: "Example user", email: "user@example.com",
						password: "foobar", password_confirmation: "foobar")
	end

	test "should be valid" do 
		assert @user.valid?
	end

	test "name should be present" do 
		@user.name = "     "
		assert_not @user.valid?
	end

	test "email should be present" do
		@user.email = "    "
		assert_not @user.valid?
	end

	test "name should be less than 51 chars" do
		@user.name = "a"*51
		assert_not @user.valid?
	end

	test "email can't exceed max length" do
		@user.email = "a"*256
		assert_not @user.valid?
	end

	test "valid emails should be considered valid" do
	  	valid_addresses = %w[user@example.com USER@example.org U-SER@test.net]
	    valid_addresses.each do |address|
	      @user.email = address
	      assert @user.valid?, "#{address.inspect} should be valid"
	    end
	end

	test "invalid emails should be considered invalid" do
		invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
		invalid_addresses.each do |address|
			@user.email = address
			assert_not @user.valid?, "#{address.inspect} should be invalid"                        
		end
	end

	test "duplicate emails should be invalid" do 
		duplicate_user = @user.dup
		duplicate_user.email = @user.email.upcase
		@user.save
		assert_not duplicate_user.valid?
	end

	test "email addresses should be saved as lower-case" do
    	mixed_case_email = "Foo@ExAMPle.CoM"
	    @user.email = mixed_case_email
    	@user.save
    	assert_equal mixed_case_email.downcase, @user.reload.email
  	end

	test "password should be longer than the minimum" do
		@user.password = @user.password_confirmation = "a"*5
		assert_not @user.valid?
	end

	test "authenticated? should return false for a user with nil digest" do
    	assert_not @user.authenticated?(:remember, '')
  	end

  	test "deleted user should delete microposts" do
  		@user.save
  		@user.microposts.create(content: "wow thats cool")
  		assert_difference 'Micropost.count', -1 do
      		@user.destroy
    	end
  	end

  	test "should be able to follow and unfollow" do
  		user1 = users(:user_2)
  		user2 = users(:user_3)
  		assert_not user1.following?(user2)
  		user1.follow(user2)
  		assert user1.following?(user2)
  		assert user2.followers.include?(user1)
  		user1.unfollow(user2)
  		assert_not user1.following?(user2)
  	end

  	test "feed should have the right posts" do
  		atallah = users(:atallah)
  		ben = users(:ben) #atallah follows ben
  		mavrick = users(:mavrick) #atallah doesn't follow mav
  		#should see ben's posts
  		ben.microposts.each do |post_followed|
  			assert atallah.feed.include?(post_followed)
  		end	
  		#shouldn't see mav's posts
  		mavrick.microposts.each do |post_not_followed|
  			assert_not atallah.feed.include?(post_not_followed)
  		end
  		#should see own posts
  		atallah.microposts.each do |own_post|
  			assert atallah.feed.include?(own_post)
  		end

  	end

  	test "should see reposted posts" do
  		atallah = users(:atallah)
  		ben = users(:ben) #atallah follows ben
  		mavrick = users(:mavrick) #atallah doesn't follow mav
  		mavrick.microposts.each do |reposted_post|
  			ben.reposts.create(micropost: reposted_post)
  			assert atallah.feed.include?(reposted_post)
  		end
  		
  	end

end
