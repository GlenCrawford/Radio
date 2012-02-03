class AddTimeZoneToRadioApps < ActiveRecord::Migration
  def self.up
    add_column :radio_apps, :time_zone, :string
  end

  def self.down
    remove_column :radio_apps, :time_zone
  end
end
