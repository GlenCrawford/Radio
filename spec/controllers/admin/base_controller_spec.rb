require 'spec_helper'

describe Admin::BaseController do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @user = users :josh
  end

  describe :index do
    it "should not authenticate user for GET index" do
      get :index

      response.code.should == "401"
      response.content_type.should == "text/html"
      response.body.should == "You need to log in first!"
    end

    it "should GET index" do
      sign_in @user

      get :index

      response.should be_success
      response.should render_template("admin/base/index")
      response.should render_template("layouts/admin")
    end
  end
end
