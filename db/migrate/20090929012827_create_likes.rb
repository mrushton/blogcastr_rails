class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.integer :user_id, :null => false
      t.integer :blogcast_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :likes
  end
end
