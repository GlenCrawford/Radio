class AddBackgroundToRailsApps < ActiveRecord::Migration
  def self.up
    add_column :radio_apps, :background_file_name, :string
    add_column :radio_apps, :background_content_type, :string
    add_column :radio_apps, :background_file_size, :integer
  end

  def self.down
    remove_column :radio_apps, :background_file_size
    remove_column :radio_apps, :background_content_type
    remove_column :radio_apps, :background_file_name
  end
end
