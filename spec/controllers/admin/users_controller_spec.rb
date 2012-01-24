require 'spec_helper'

describe Admin::UsersController do
  render_views
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @current_user = users :josh
    @cookies = mock "cookies"
  end

  {
    :index => {:method => :get, :data => nil},
    :new => {:method => :get, :data => nil},
    :create => {:method => :post, :data => {:user => {}}},
    :edit => {:method => :get, :data => {:id => 1}},
    :update => {:method => :put, :data => {:id => 1, :user => {}}},
    :destroy => {:method => :delete, :data => {:id => 1}}
  }.each do |action, options|
    it "should not authorize logged out user - GET #{action}" do
      send options[:method], action, options[:data]

      response.code.should == "401"
      response.content_type.should == "text/html"
      response.body.should == "You need to log in first!"
    end
  end

  describe :index do
    it "should GET index" do
      @cookies.stub!(:[])
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@current_user.id)

      get :index

      assigns(:users).should == User.all.sort{|a, b| a.full_name <=> b.full_name}

      response.should be_success
      response.should render_template("admin/users/index")
      response.should render_template("layouts/admin")
    end
  end

  describe :new do
    it "should GET new" do
      @cookies.stub!(:[])
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@current_user.id)

      get :new

      user = assigns :user
      user.should be_an_instance_of(User)
      user.should be_a_new(User)

      response.should be_success
      response.should render_template("admin/users/new")
      response.should render_template("layouts/admin")
    end
  end

  describe :create do
    before(:each) do
      @user_data = {
        :first_name => "Joanna",
        :last_name => "Stern",
        :picture => Rack::Test::UploadedFile.new(Rails.root.join("spec", "assets", "With smiles like that they must be stoned - TruShu.jpg"), "image/jpeg")
      }
    end

    it "should POST create - but not be successful (missing attribute)" do
      @cookies.stub!(:[])
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@current_user.id)

      expect {
        post :create, :user => @user_data.reject{|key, value| key == :last_name}
      }.to change(User, :count).by(0)

      user = assigns :user
      user.should be_an_instance_of(User)
      user.should be_a_new(User)
      user.should_not be_valid
      user.first_name.should == @user_data[:first_name]

      response.should be_success
      response.should render_template("admin/users/new")
      response.should render_template("layouts/admin")
    end

    it "should POST create - successfully" do
      @cookies.stub!(:[])
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@current_user.id)

      expect {
        post :create, :user => @user_data
      }.to change(User, :count).by(1)

      user = assigns :user
      user.should be_an_instance_of(User)
      user.should_not be_a_new(User)
      user.should be_valid
      user.full_name.should == "#{@user_data[:first_name]} #{@user_data[:last_name]}"

      request.flash[:notice].should == "User '#{@user_data[:first_name]} #{@user_data[:last_name]}' has been created!"

      response.should be_redirect
      response.should redirect_to admin_users_path
    end
  end

  describe :edit do
    it "should GET edit" do
      @cookies.stub!(:[])
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@current_user.id)

      user = users :paul

      get :edit, :id => user.id

      assigns(:user).should == user

      response.should be_success
      response.should render_template("admin/users/edit")
      response.should render_template("layouts/admin")
    end
  end

  describe :update do
    before(:each) do
      @user = users :paul
      @user_data = {
        :first_name => (@user.first_name + "2"),
        :last_name => (@user.last_name + "2")
      }
    end

    it "should PUT update - but not successfully (missing attribute)" do
      @cookies.stub!(:[])
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@current_user.id)

      @user_data[:last_name] = ""

      put :update, :id => @user.id, :user => @user_data

      user = assigns :user
      user.should be_an_instance_of(User)
      user.should_not be_valid
      user.id.should == @user.id
      user.first_name.should == @user_data[:first_name]
      user.last_name.should == ""

      response.should be_success
      response.should render_template("admin/users/edit")
      response.should render_template("layouts/admin")
    end

    it "should PUT update - successfully" do
      @cookies.stub!(:[])
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@current_user.id)

      put :update, :id => @user.id, :user => @user_data

      user = assigns :user
      user.should be_an_instance_of(User)
      user.should be_valid
      user.id.should == @user.id
      user.first_name.should == @user_data[:first_name]
      user.last_name.should == @user_data[:last_name]

      request.flash[:notice].should == "User '#{@user_data[:first_name]} #{@user_data[:last_name]}' has been updated!"

      response.should be_redirect
      response.should redirect_to(admin_users_path)
    end
  end

  describe :destroy do
    it "should DELETE destroy" do
      @cookies.stub!(:[])
      controller.stub!(:cookies).and_return(@cookies)
      @cookies.should_receive(:[]).once.with(:user_id).and_return(@current_user.id)

      user = users :paul

      expect {
        delete :destroy, :id => user.id
      }.to change(User, :count).by(-1)

      lambda {
        user.reload
      }.should raise_error(ActiveRecord::RecordNotFound, "Couldn't find User with ID=#{user.id}")

      assigns(:user).should == user

      request.flash[:notice].should == "User '#{user.full_name}' has been deleted!"

      response.should be_redirect
      response.should redirect_to(admin_users_path)
    end
  end
end
