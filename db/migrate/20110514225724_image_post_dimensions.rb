class ImagePostDimensions < ActiveRecord::Migration
  def self.up
    add_column :posts, :image_width, :integer 
    add_column :posts, :image_height, :integer
  end

  def self.down
    remove_column :posts, :image_width
    remove_column :posts, :image_height
  end
end
