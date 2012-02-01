class Veto < ActiveRecord::Base
  belongs_to :user
  belongs_to :track

  validates_presence_of :user, :track

  # Note: the below scope will get the most recent of each track's vetoes.
  scope :distinct_by_track, where("id IN (SELECT DISTINCT ON (track_id) id FROM vetoes ORDER BY track_id ASC, created_at DESC)")
  scope :recent_first, order("created_at DESC")
end
