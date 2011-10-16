class DJ < ActiveRecord::Base
  belongs_to :radio, :class_name => "RadioApp", :inverse_of => :dj
  has_one :playlist, :dependent => :destroy, :inverse_of => :dj

  validates_presence_of :radio, :playlist

  before_create :check_no_existing_of_this_dj
  before_validation :set_radio, :check_playlist
  validate :check_type

  class_inheritable_accessor :dj_name, :dj_description # Lesson learned: don't accidentally try and override a model's "name" method!

  def self.get
    raise "You can only get a specific DJ, not the base one." if name == "DJ"
    first
  end

  def run
    raise NotImplementedError
  end

  def name
    self.class.dj_name
  end

  def description
    self.class.dj_description
  end

  # Re-implement as needed in DJs.
  def need_to_run?
    playlist.tracks.size < 20
  end

  private

  def set_radio
    self.radio ||= RadioApp.get
  end

  def check_playlist
    build_playlist unless playlist
  end

  def check_type
    errors.add :base, "You have to specify a specific DJ; you cannot create an instance of DJ itself." unless type.present?
  end

  def check_no_existing_of_this_dj
    raise "There is already an instance of #{self.class.name}." if type && DJ.find_by_type(type)
  end
end
