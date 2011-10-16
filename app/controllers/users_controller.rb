class UsersController < ApplicationController
  skip_before_filter :authenticate, :only => [:login]

  def login
    user_id = params[:user_id].to_i
    if User.where(:id => user_id).first
      cookies[:user_id] = user_id
      render :status => :accepted, :json => response_for_client(:playlist, :player).merge(:next_update_time => 5.seconds)
    else
      render :status => :unauthorized, :nothing => true
    end
  end
end
