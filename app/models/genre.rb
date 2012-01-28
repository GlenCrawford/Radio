class Genre < ActiveRecord::Base
  has_and_belongs_to_many :tracks

  validates_presence_of :name
  validates_uniqueness_of :name
  validate :check_valid_name

  before_validation :downcase_name

  LAST_FM_TAGS_TO_IGNORE = [
    "hybrid", "albums i own", "classic", "80s", "canadian", "favourite albums",
    "chris cornell", "70s", "favorite albums", "singer-songwriter", "darude",
    "60s", "female vocalists", "british", "blue-eyed soul", "pink floyd", "cover",
    "90s", "enz", "barturismooth", "one little indian", "00s", "kenny",
    "maksim mrvica", "top albums", "albums in my itunes",
    "records i should listen more often", "my private work station", "new to my ears",
    "do kupienia", "totec radio", "robert miles", "inspirational", "kiwi music",
    "beautiful", "deep", "daydream", "female fronted metal", "1985", "1969"
  ]

  def self.is_valid_genre?(genre_name)
    not LAST_FM_TAGS_TO_IGNORE.include?(genre_name.downcase)
  end

  def self.random(number_to_get = 5)
    number_of_genres = count
    if number_of_genres < number_to_get
      raise "There aren't enough Genres (need at least #{number_to_get})."
    else
      genres = []
      until genres.size == number_to_get
        new_genre = find :first, :offset => rand(number_of_genres)
        genres << new_genre unless genres.include?(new_genre)
      end
      genres
    end
  end

  def get_random_tracks(options = {})
    options[:maximum_total_length] ||= 1.hour
    random_tracks = []
    all_tracks = tracks.to_a.shuffle
    while random_tracks.sum{|track| track.length} < options[:maximum_total_length] do
      break unless all_tracks.any?
      random_tracks << all_tracks.shift
    end
    random_tracks
  end

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end

  def check_valid_name
    return unless name
    errors.add(:base, "You cannot create a Genre with an invalid name") unless Genre.is_valid_genre?(name)
  end
end
