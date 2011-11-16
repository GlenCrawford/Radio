require File.dirname(__FILE__) + '/../spec_helper'

# NOTE: We'll use RadioController as the subject of these tests,
# but we're really testing the features of ApplicationController.
describe RadioController do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @user = users :josh
    @radio = radio_apps :radio

    @cookies = mock "cookies"
  end

  describe :authenticate do
    it "should recognize user and continue with action" do
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@user.id)

      get :update, :request => "all"

      assigns(:user).should == @user

      response.should be_success
    end

    it "should not recognize user when invalid user ID is sent" do
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(999)

      lambda {
        get :update, :request => "all"
      }.should raise_error(ActiveRecord::RecordNotFound, "Couldn't find User with ID=999")
    end

    it "should render error message if user does not have a user ID in their cookie" do
      get :update, :request => "all"

      response.should_not be_success
      response.code.should == "401"
      response.content_type.should == "text/html"
      response.body.should == "You need to log in first!"
    end
  end

  describe :logged_in? do
    it "should know that user is logged in" do
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@user.id)

      get :update, :request => "all"

      controller.send(:logged_in?).should be true
    end

    it "should know that the user is not logged in" do
      get :update, :request => "all"

      controller.send(:logged_in?).should be false
    end
  end

  describe :get_radio do
    it "should have retrieved the radio instance" do
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@user.id)

      get :update, :request => "all"

      assigns(:radio).should == @radio
    end
  end

  describe :response_for_client do
    before(:each) do
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@user.id)

      @full_expected_response = {
        :playlist => @radio.dj.playlist.serialize_for_client,
        :player => {
          :status => Player.status,
          :current_track => @radio.dj.playlist.current_track.id
        }
      }
    end

    it "should get all response data" do
      get :update, :request => "all"

      response.body.should == @full_expected_response.merge(:next_update_time => 5.seconds).to_json
      controller.send(:response_for_client, :playlist, :player).should == @full_expected_response
    end

    it "should get one piece of response data" do
      expected_response = @full_expected_response.select{|key, value| key == :player}

      get :update, :request => "player"

      response.body.should == expected_response.merge(:next_update_time => 5.seconds).to_json
      controller.send(:response_for_client, :player).should == expected_response
    end

    it "should not fail with no specific data requested" do
      get :update, :request => ""

      response.body.should == {:next_update_time => 5.seconds}.to_json
      controller.send(:response_for_client).should == {}
    end

    it "should ignore any unrecognized piece of data" do
      get :update, :request => "not_real"

      response.body.should == {:next_update_time => 5.seconds}.to_json
      controller.send(:response_for_client, :not_real).should == {}
    end
  end

  describe :current_user do
    it "should return current user when logged in" do
      controller.stub(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@user.id)

      get :update, :request => "all"

      controller.send(:current_user).should == @user
    end

    it "should return nothing when not logged in" do
      get :update, :request => "all"

      controller.send(:current_user).should be_nil
    end
  end

  describe :record_user_visit do
    it "should update user's last seen at timestamp when user makes a request" do
      controller.stub(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@user.id)

      time = Time.parse "2011-11-17 11:06:33"
      Time.should_receive(:now).any_number_of_times.and_return(time)

      @user.last_seen_at.should_not == time

      get :update, :request => "all"

      @user.reload
      @user.last_seen_at.should == time
    end
  end
end
