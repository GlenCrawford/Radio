class CreateRadioApps < ActiveRecord::Migration
  def self.up
    create_table :radio_apps do |t|
      t.string :name
      t.string :music_path

      t.timestamps
    end
  end

  def self.down
    drop_table :radio_apps
  end
end
