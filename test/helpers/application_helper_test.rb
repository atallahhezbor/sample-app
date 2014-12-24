require 'test_helper'

class ApplicationTestHelper < ActionView::TestCase

	test "full title helper" do
		assert_equal full_title,		 	"Ruby on Rails Tutorial"
		assert_equal full_title("Help"),	"Help | Ruby on Rails Tutorial"
	end
end