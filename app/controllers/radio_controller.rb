class RadioController < ApplicationController
  skip_before_filter :authenticate, :only => [:index]
  before_filter :get_track, :only => [:play, :pause, :veto]
  before_filter :maintain_playlist

  def index
    @users = User.by_name
  end

  def update
    result = params[:request].to_sym == :all ? response_for_client(:playlist, :player) : response_for_client(params[:request].to_sym)
    render :status => :ok, :json => result.merge(:next_update_time => 5.seconds)
  end

  def play
    until Player.play @track
      @track = @radio.dj.playlist.remove_current_track
    end
    render :status => :ok, :json => response_for_client(:playlist, :player) if params[:action].to_sym == :play
  end

  def pause
    Player.pause
    render :status => :ok, :json => response_for_client(:player)
  end

  def veto
    @user.veto @track
    @track = @radio.dj.playlist.remove_current_track
    play
    render :status => :ok, :json => response_for_client(:playlist, :player)
  end

  private

  def get_track
    @track = @radio.dj.playlist.get_track :id => params[:track]
    render :status => :not_acceptable, :json => response_for_client(:playlist, :player) unless @track == @radio.dj.playlist.current_track
  end

  def maintain_playlist
    @radio.dj.run if @radio.dj.need_to_run?
  end
end
