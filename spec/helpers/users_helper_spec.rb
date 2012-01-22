require 'spec_helper'

describe UsersHelper do
  before(:each) do
    @user = users :josh
  end

  describe :user_picture do
    it "should build picture image tag for user - default size" do
      helper.user_picture(@user).should == "<img alt=\"#{@user.name}\" height=\"80\" src=\"#{@user.picture.url}\" width=\"80\" />"
    end

    it "should build picture image tag for user - other size" do
      helper.user_picture(@user, :small).should == "<img alt=\"#{@user.name}\" height=\"45\" src=\"#{@user.picture.url}\" width=\"45\" />"
    end
  end
end
