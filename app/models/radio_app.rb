class RadioApp < ActiveRecord::Base
  acts_as_singleton

  has_one :dj, :class_name => "DJ", :foreign_key => :radio_id, :inverse_of => :radio

  has_attached_file :background, :url => "/images/radio_backgrounds/:id/:style_:basename.:extension", :path => ":rails_root/public/images/radio_backgrounds/:id/:style_:basename.:extension"

  validates_presence_of :name, :message => "must be set to the name of the Radio"
  validates_presence_of :music_path, :message => "must be set to the path of the music directory"
  validate :check_dj

  validates_attachment_presence :background
  validates_attachment_content_type :background, :content_type => ["image/jpeg", "image/gif", "image/png"]

  def self.get
    instance
  end

  def djs
    DJ.all.sort{|a, b| a.name.downcase <=> b.name.downcase} # Name is no longer stored in the database.
  end

  private

  def check_dj
    errors[:base] << "You need to select a DJ for this Radio!" unless dj
  end
end
