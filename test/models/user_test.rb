require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "me", email: "me@aol.com", password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid user" do
    assert @user.valid?
  end
  
  test "name needs to be present" do
    @user.name = "    "
    assert_not @user.valid?
  end
  
  test "email needs to be present" do
    @user.email = "   "
    assert_not @user.valid?
  end
  
  test "name not too long" do
    @user.name = "a" * 60
    assert_not @user.valid?
  end
  
  test "email not too long" do
    @user.email = "a" * 245 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  test "emails are unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "password needs minimum length" do
    @user.password = @user.password_confirmation = "a" * 5 
    assert_not @user.valid?
  end
  
  test "saved email is lower case" do
    @user.email = "FOOBAR@COMCAST.NET"
    @user.save
    assert_equal @user.reload.email, @user.email.downcase
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "microposts deleted when user destroyed" do
    @user.save
    @user.microposts.create!(content: "gibs")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end
  
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end
  
  test "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # Posts from self
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
