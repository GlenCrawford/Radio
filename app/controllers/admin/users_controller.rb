class Admin::UsersController < Admin::BaseController
  before_filter :get_user

  def index
    @users = User.order "first_name ASC, last_name ASC"
  end

  def show
    @veto_stats = {
      :recent => @user.recent_vetoes(5, true).map{|veto| {:track => veto.track, :vetoed_at => veto.created_at}},
      :common => @user.most_commonly_vetoed_tracks(5)
    }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    if @user.save
      redirect_to admin_users_path, :notice => "User '#{@user.full_name}' has been created!"
    else
      render :action => "new"
    end
  end

  def edit
    #
  end

  def update
    if @user.update_attributes params[:user]
      redirect_to admin_users_path, :notice => "User '#{@user.full_name}' has been updated!"
    else
      render :action => "edit"
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, :notice => "User '#{@user.full_name}' has been deleted!"
  end

  private

  def get_user
    @user = User.find params[:id] if params[:id]
  end
end
