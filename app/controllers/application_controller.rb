class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate, :get_radio, :record_user_visit, :set_time_zone

  private

  def authenticate
    user_id = cookies[:user_id]
    if user_id
      @user = User.find user_id
    else
      render :status => :unauthorized, :text => "You need to log in first!"
    end
  end

  def logged_in?
    not @user.nil?
  end

  def get_radio
    @radio = RadioApp.get
  end

  def response_for_client(*responses)
    final_response = {}
    responses.each do |response|
      case response
        when :playlist
          final_response[response] = @radio.dj.playlist.serialize_for_client
        when :player
          final_response[response] = {
            :status => Player.status,
            :current_track => @radio.dj.playlist.current_track.id
          }
      end
    end
    final_response
  end

  def current_user
    @user if @user.is_a? User
  end

  def record_user_visit
    current_user.seen_now if logged_in?
  end

  def set_time_zone
    Time.zone = @radio.time_zone
  end
end
