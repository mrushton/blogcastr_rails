class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :type, :null => false
      t.integer :user_id, :null => false
      t.integer :blogcast_id, :null => false
      t.string :from, :null => false
      #MVR - text comments
      t.string :text
      #MVR - image comments
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
