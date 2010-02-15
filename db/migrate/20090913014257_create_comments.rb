class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :user_id, :null => false
      t.integer :blogcast_id, :null => false
      t.string :from, :null => false
      t.string :text, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
