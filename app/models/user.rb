class User < ActiveRecord::Base
  has_many :vetoes, :dependent => :destroy

  has_attached_file :picture, :url => "/images/user_pictures/:id/:style_:filename", :path => ":rails_root/public/images/user_pictures/:id/:style_:basename.:extension"

  validates_presence_of :first_name, :last_name
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, :content_type => ["image/jpeg", "image/gif", "image/png"]
  validate :last_seen_at_cant_be_in_the_future

  scope :by_name, order(:first_name, :last_name)
  scope :seen_in_the_last, lambda {|period|
    where(User.arel_table[:last_seen_at].gt(period.ago))
  }

  def name
    "#{first_name} #{last_name[0,1]}."
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def veto(track)
    vetoes.create :track => track
  end

  def seen_at(last_seen_time)
    update_attribute :last_seen_at, last_seen_time
  end

  def seen_now
    seen_at Time.now
  end

  def recent_vetoes(number_to_get, distinct_by_track = false)
    scope = vetoes.recent_first.limit number_to_get
    distinct_by_track ? scope.distinct_by_track : scope
  end

  def most_commonly_vetoed_tracks(number_to_get)
    track_ids = vetoes.map(&:track_id).group_by{|element| element}.values.sort{|a, b| b.size <=> a.size}[0...number_to_get].map(&:first)
    tracks = track_ids.map{|track_id| Track.find(track_id)}
    tracks.map do |track|
      user_vetoes_for_track = vetoes.where(:track_id => track.id)
      last_user_veto_for_track = user_vetoes_for_track.recent_first.first
      {:track => track, :vetoed_at => last_user_veto_for_track.created_at, :count => user_vetoes_for_track.count}
    end
  end

  private

  def last_seen_at_cant_be_in_the_future
    return unless last_seen_at
    errors.add :last_seen_at, "can't be in the future" if last_seen_at > Time.now
  end
end
