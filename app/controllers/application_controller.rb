class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate, :get_radio

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
end
