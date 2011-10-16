class User < ActiveRecord::Base
  has_many :vetoes, :dependent => :destroy

  has_attached_file :picture, :url => "/images/user_pictures/:id/:style_:filename", :path => ":rails_root/public/images/user_pictures/:id/:style_:basename.:extension"

  validates_presence_of :first_name, :last_name
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, :content_type => ["image/jpeg", "image/gif", "image/png"]

  scope :by_name, order(:first_name, :last_name)

  def name
    "#{first_name} #{last_name[0,1]}."
  end

  def veto(track)
    vetoes.create :track => track
  end
end
