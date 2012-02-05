module Radio
  module Player
    module Exceptions
      class PlayerNotFoundError < StandardError; end
      class InvalidPlayerHostAddress < StandardError; end
    end
  end
end

require "raop"

class Player
  attr_reader :status
  @@player = nil

  def self.method_missing(method, *args, &block)
    raise Radio::Player::Exceptions::PlayerNotFoundError, "A Radio Player has not yet been created." unless @@player

    return super unless [:play, :pause, :status, :play_callback].include? method
    @@player.send method, *args, &block
  end

  def initialize(host_address)
    return @@player if @@player

    @status = :paused
    @connected = false
    @volume = -40
    self.host = host_address

    create_client # But don't connect yet.

    @@player = self
  end

  private

  def host=(host_address)
    raise Radio::Player::Exceptions::InvalidPlayerHostAddress, "The host address must be a String." unless host_address.is_a? String

    disconnect if @client && connected?
    @host = host_address

    if @client
      @client = nil
      create_client
    end
  end

  def create_client
    return @client if @client

    @client = Net::RAOP::Client.new @host
  end

  def connect
    return if connected?

    @client.connect
    @client.volume = @volume

    @connected = true
  end

  def disconnect
    return unless connected?

    @client.disconnect

    @connected = false
  end

  def connected?
    @connected
  end

  def decode_file(path)
    decode_command = "lame --decode #{path} -"
    IO.popen decode_command
  end

  def play_callback
    next_track = DJ.playlist.remove_current_track
    play next_track
  end

  def play(track)
    @status = :playing
    track.increment_play_count
    connect unless connected?
    @client.play decode_file(track.file_path)
    true
  end

  def pause
    @status = :paused
    disconnect if connected?
    true
  end
end
