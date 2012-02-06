class AddDataToDjs < ActiveRecord::Migration
  def self.up
    add_column :djs, :data, :text
  end

  def self.down
    remove_column :djs, :data
  end
end
