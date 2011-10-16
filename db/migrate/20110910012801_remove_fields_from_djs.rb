class RemoveFieldsFromDjs < ActiveRecord::Migration
  def self.up
    remove_column :djs, :name
    remove_column :djs, :description
  end

  def self.down
    add_column :djs, :description, :text
    add_column :djs, :name, :string
  end
end
