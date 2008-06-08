require File.dirname(__FILE__) + '/../spec_helper'

describe UserRole do
  before(:each) do
    @user_role = UserRole.new
  end

  it "should be valid" do
    @user_role.should be_valid
  end

  describe "belongs to" do
    it "user" do
      @user_role.user = User.new
    end

    it "role" do
      @user_role.role = Role.new
    end

    it "granting_user" do
      @user_role.granting_user = User.new
    end
  end
end
