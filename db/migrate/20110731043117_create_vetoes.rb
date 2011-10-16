class CreateVetoes < ActiveRecord::Migration
  def self.up
    create_table :vetoes do |t|
      t.references :user
      t.references :track
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :vetoes
  end
end
