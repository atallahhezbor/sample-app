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
                           foo@bar_baz.com foo@bar+baz.com]
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

	test "password should be longer than the minimum" do
		@user.password = @user.password_confirmation = "a"*5
		assert_not @user.valid?
	end


end
