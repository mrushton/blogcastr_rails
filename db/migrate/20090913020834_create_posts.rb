class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :type, :null => false
      t.integer :user_id, :null => false
      t.integer :blogcast_id, :null => false
      t.string :from, :null => false
      #MVR - text posts
      t.string :text
      #MVR - image posts
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      #MVR - comment posts
      t.integer :comment_id
      #MVR - reposts
      t.integer :parent_id
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
