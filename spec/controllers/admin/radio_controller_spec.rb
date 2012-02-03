require 'spec_helper'

describe Admin::RadioController do
  render_views
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @user = users :josh
    @radio = RadioApp.get
  end

  {
    :index => {:method => :get, :data => nil},
    :update => {:method => :put, :data => {:id => 1, :radio_app => {}}}
  }.each do |action, options|
    it "should not authorize logged out user - #{options[:method].to_s.upcase} #{action}" do
      send options[:method], action, options[:data]

      response.code.should == "401"
      response.content_type.should == "text/html"
      response.body.should == "You need to log in first!"
    end
  end

  describe :index do
    it "should GET index" do
      sign_in @user

      get :index

      assigns(:radio).should == @radio

      response.should be_success
      response.should render_template("admin/radio/index")
      response.should render_template("layouts/admin")
    end
  end

  describe :update do
    before(:each) do
      sign_in @user

      @radio_data = {
        :name => "Radio Verge",
        :music_path => "C:\\Users\\John Smith\\Music",
        :background => uploaded_image,
        :time_zone => "Singapore"
      }

      @dj = djs :random_genre_dj
      @dj_data = {
        :id => @dj.id
      }
    end

    it "should update Radio - fail with validation errors" do
      @radio_data[:name] = ""

      put :update, :id => @radio.id, :radio_app => @radio_data, :dj => @dj_data

      radio = assigns :radio
      radio.should_not be_valid

      response.should be_success
      response.should render_template("admin/radio/index")
      response.should render_template("layouts/admin")
    end

    it "should update Radio - successful" do
      put :update, :id => @radio.id, :radio_app => @radio_data, :dj => @dj_data

      radio = assigns :radio
      radio.should be_valid
      radio.name.should == @radio_data[:name]
      radio.music_path.should == @radio_data[:music_path]
      radio.background.should be_an_instance_of(Paperclip::Attachment)
      radio.time_zone.should == @radio_data[:time_zone]
      radio.dj.dj_name.should == @dj.dj_name

      request.flash[:notice].should == "Radio settings have been updated!"

      response.should be_redirect
      response.should redirect_to(admin_radio_index_path)
    end
  end
end
