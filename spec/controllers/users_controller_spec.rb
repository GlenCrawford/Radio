require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  render_views
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  describe :login do
    before(:each) do
      @cookies = mock "cookies"
      @cookies.stub! :[]=
      controller.stub!(:cookies).and_return @cookies
    end

    it "should recognize user, set cookie and serve content" do
      @cookies.should_receive(:[]=).with(:user_id, users(:josh).id)

      post :login, :user_id => users(:josh).id

      response.should be_success
      response.response_code.should == 202

      response.body.should =~ /playlist/
      response.body.should =~ /player/
      response.body.should =~ /next_update_time/
    end

    it "should not recognize invalid user" do
      post :login, :user_id => 565456464

      response.should_not be_success
      response.response_code == 401

      response.body.strip.should == ""
    end

    it "should retrieve radio app" do
      post :login, :user_id => users(:josh).id

      radio = assigns :radio
      radio.should_not be_nil
      radio.should be_an_instance_of(RadioApp)
    end
  end
end
