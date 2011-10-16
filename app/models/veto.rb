class Veto < ActiveRecord::Base
  belongs_to :user
  belongs_to :track

  validates_presence_of :user, :track
end
