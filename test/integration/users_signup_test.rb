require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "successful user sign up" do 
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: {name: "nick", email: "me@user.com", password: "choppy", password_confirmation: "choppy"}
    end
    assert_template 'users/show'
  end
  
  test "unsuccessful user sign up" do 
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: {name: "nick", email: "me@user.com", password: "choppy", password_confirmation: "choppier"}
    end
    assert_template 'users/new'
  end
end
