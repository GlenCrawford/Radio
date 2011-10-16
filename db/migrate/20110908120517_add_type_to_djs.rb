class AddTypeToDjs < ActiveRecord::Migration
  def self.up
    add_column :djs, :type, :string
  end

  def self.down
    remove_column :djs, :type
  end
end
