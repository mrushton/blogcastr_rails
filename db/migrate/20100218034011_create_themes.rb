class CreateThemes < ActiveRecord::Migration
  def self.up
    create_table :themes do |t|
      t.string :title
      t.string :background_image_file_name
      t.string :background_image_content_type
      t.integer :background_image_file_size
      t.boolean :tile_background_image
      t.boolean :scroll_background_image
      t.string :background_color
      t.string   "thumbnail_file_name"
      t.string   "thumbnail_content_type"
      t.integer  "thumbnail_file_size"
      t.timestamps
    end
  end

  def self.down
    drop_table :themes
  end
end
