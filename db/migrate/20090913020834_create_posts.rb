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
      #MVR - audio posts
      t.string :audio_file_name
      t.string :audio_content_type
      t.integer :audio_file_size
      t.datetime :audio_updated_at
      #MVR - temporary file used for post processing of audio
      t.string :audio_post_process_file_name
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
