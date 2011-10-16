class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.text :file_path
      t.string :title
      t.string :artist
      t.string :album
      t.integer :track_number
      t.text :image
      t.date :release_date
      t.references :playlist

      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
