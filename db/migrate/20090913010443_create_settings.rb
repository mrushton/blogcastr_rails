class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer :user_id, :null => false
      t.string :full_name
      t.string :motto
      t.string :location
      t.string :bio
      t.string :web
      t.string :time_zone
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.integer :theme_id, :null => false, :default => 1
      t.boolean :use_background_image, :null => false, :default => false
      t.string :background_image_file_name
      t.string :background_image_content_type
      t.integer :background_image_file_size
      t.datetime :background_image_updated_at
      t.boolean :tile_background_image
      t.boolean :scroll_background_image
      t.string :background_color, :limit => 7
      t.boolean :mobile_confirmed
      t.string :mobile_confirmation_token, :limit => 5
      t.string :mobile_number
      t.string :carrier
      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
